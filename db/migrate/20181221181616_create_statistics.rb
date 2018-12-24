class CreateStatistics < ActiveRecord::Migration[5.2]
  def change
    create_table :statistics do |t|
      t.integer :rating_sum, default: 0
      t.integer :rating_count, default: 0
      t.numeric :rating_avg, precision: 4, scale: 2, default: 0.0
      t.references :post, index: { unique: true }, null: false, foreign_key: {on_delete: :cascade}
    end

    execute <<-SQL
      CREATE OR REPLACE FUNCTION recount_average() RETURNS trigger AS '
      DECLARE
        current_record statistics%ROWTYPE;
        curr_avg statistics.rating_avg%TYPE;
        curr_sum statistics.rating_sum%TYPE;
        curr_count statistics.rating_count%TYPE;
        new_rating ratings.value%TYPE;
        new_sum statistics.rating_sum%TYPE;
        new_count statistics.rating_count%TYPE;
        new_avg statistics.rating_avg%TYPE;
        current_post_id posts.id%TYPE;
      BEGIN
        current_post_id = NEW.post_id;
        
        if NOT EXISTS(SELECT * FROM statistics WHERE post_id = current_post_id) then
          INSERT INTO statistics(post_id) VALUES (current_post_id);
        end if;
        
        SELECT * INTO current_record FROM statistics WHERE post_id = current_post_id;
        curr_avg = current_record.rating_avg;
        curr_sum = current_record.rating_sum;
        curr_count = current_record.rating_count;
        new_rating = NEW.value;
        new_sum = curr_sum + new_rating;
        new_count = curr_count + 1;
        new_avg = (curr_count * curr_avg + new_rating) / new_count;
        UPDATE statistics
        SET rating_avg = new_avg,
          rating_count = new_count,
          rating_sum = new_sum
        WHERE id = current_record.id;
        RETURN NEW;
      END;
      ' LANGUAGE  plpgsql;

      CREATE TRIGGER recount_avg_rating_after_create
          AFTER INSERT ON public.ratings FOR EACH ROW
          EXECUTE PROCEDURE recount_average();
    SQL
  end
end
