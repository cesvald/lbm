# -*- encoding : utf-8 -*-
class UpdateActualCatarseFeeInProject < ActiveRecord::Migration
  def up
    execute <<-SQL
	    UPDATE projects
	    SET catarse_fee = coalesce (platform_fee, 0.13)
	    WHERE (projects.online_date IS NOT NULL AND projects.online_date < to_date('2015-05-01', 'yyyy-mm-dd')) OR (projects.created_at < to_date('2015-05-01', 'yyyy-mm-dd') AND projects.online_date IS NULL);
    SQL
    execute <<-SQL
      UPDATE projects
      SET catarse_fee = coalesce (platform_fee, 0.14)
      WHERE (projects.online_date IS NOT NULL AND projects.online_date >= to_date('2015-05-01', 'yyyy-mm-dd')) OR (projects.created_at >= to_date('2015-05-01', 'yyyy-mm-dd') AND projects.online_date IS NULL);
    SQL
  end

  def down
  	execute <<-SQL
    UPDATE projects
    	SET catarse_fee = NULL
    SQL
  end
end
