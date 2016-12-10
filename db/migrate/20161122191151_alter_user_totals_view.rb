# -*- encoding : utf-8 -*-
class AlterUserTotalsView < ActiveRecord::Migration
  def change
    execute <<-SQL
      DROP VIEW user_totals;
      CREATE OR REPLACE VIEW user_totals AS 
      SELECT 
        b.user_id as id,
        b.user_id, 
        count(DISTINCT(b.project_id)) as total_backed_projects,
        sum(b.value) AS sum, 
        count(*) AS count,
        SUM(CASE
          WHEN p.state = 'successful' AND b.state = 'confirmed' AND b.credits THEN b.value
          ELSE 0
        END) AS credits_used,
        sum(CASE
          WHEN p.state = 'failed' AND ((p.online_date + interval '1 day' * p.online_days + interval '120' day)  > current_timestamp) AND NOT b.credits AND b.state = 'confirmed' THEN b.value
          -- I've backed a successful project with credits
          WHEN p.state = 'successful' AND b.state = 'confirmed' AND b.credits AND (b.created_at + interval '120' day > current_timestamp ) THEN b.value * (-1)::numeric
          ELSE 0
        END) AS credits
      FROM 
        backers b
        JOIN projects p ON (b.project_id = p.id)
      WHERE b.state in ('confirmed', 'requested_refund', 'refunded')
      GROUP BY b.user_id;
    SQL
  end

  def down
    execute <<-SQL
      DROP VIEW user_totals;
      CREATE OR REPLACE VIEW user_totals AS 
      SELECT 
        b.user_id as id,
        b.user_id, 
        count(DISTINCT(b.project_id)) as total_backed_projects,
        sum(b.value) AS sum, 
        count(*) AS count,
        sum(CASE 
          -- I've backed a successful (or unfinished) project with money
          WHEN (p.state <> 'failed') AND NOT b.credits THEN 0 
          -- I've backed a failed project with credits
          WHEN p.state = 'failed' AND b.credits THEN 0
          -- I've backed a failed project with money and asked for refund xor I've backed a failed project with credits
          WHEN p.state = 'failed' AND ((b.state='requested_refund' AND NOT b.credits) OR (b.credits AND NOT b.state='requested_refund')) THEN 0
          -- I've backed a failed project with money and did not ask for refund and the project has less than 120 days since finished
          WHEN p.state = 'failed' AND ((p.online_date + interval '1 day' * p.online_days + interval '120' day)  > current_timestamp) AND NOT b.credits AND b.state = 'confirmed' THEN b.value
          -- I've backed a successful project with credits
          WHEN p.state = 'successful' AND b.state = 'confirmed' AND b.credits AND (b.created_at + interval '120' day > current_timestamp ) THEN b.value * (-1)::numeric
          ELSE 0
        END) AS credits
      FROM 
        backers b
        JOIN projects p ON (b.project_id = p.id)
      WHERE b.state in ('confirmed', 'requested_refund', 'refunded')
      GROUP BY b.user_id;
    SQL
  end
end
