class CreateIpAddresses < ActiveRecord::Migration[5.2]
  def change
    create_table :ip_addresses do |t|
      t.inet :ip_address, index: { unique: true }, default: '0.0.0.0', null: false
      t.integer :count_noticed_authors, index: true, default: 0, null: false
      t.bigint :users, array: true, index: {using: 'gin'}, default: '{}', null: false
    end

    execute <<-SQL
      CREATE OR REPLACE FUNCTION add_author_ip() RETURNS trigger AS '
      DECLARE
        current_ip_address posts.author_ip%TYPE;
        current_author posts.user_id%TYPE;
      BEGIN
        current_ip_address = NEW.author_ip;
        current_author = NEW.user_id;

        if EXISTS(SELECT * FROM ip_addresses WHERE ip_address = current_ip_address AND ARRAY[current_author] <@ users) then
          RETURN NEW;
        elseif  EXISTS(SELECT * FROM ip_addresses WHERE ip_address = current_ip_address) then
          UPDATE
            ip_addresses
          SET
            count_noticed_authors = count_noticed_authors + 1,
            users = array_append(users, current_author)
          WHERE
            ip_address = current_ip_address;
        else
          INSERT INTO ip_addresses(ip_address, count_noticed_authors, users) VALUES (current_ip_address, 1, ARRAY[NEW.user_id]);
        end if;

        RETURN NEW;

      END;
      ' LANGUAGE  plpgsql;

      CREATE TRIGGER add_author_using_ip_address
      AFTER INSERT ON public.posts FOR EACH ROW
      EXECUTE PROCEDURE add_author_ip();

    SQL

  end
end
