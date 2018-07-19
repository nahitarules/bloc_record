require 'sqlite3'

 module Selection

   def find(*ids)
     ids.each do |i|
       unless i < 0 || i.is_a?(Integer) = false
         if ids.length == 1
           find_one(ids.first)
         else
           rows = connection.execute <<-SQL
           SELECT #{columns.join ","} FROM #{table}
           WHERE id IN (#{ids.join(",")});
           SQL

           rows_to_array(rows)
         end
     end
   end

   def find_one(id)
     unless i < 0 || i.is_a?(Integer) = false
       row = connection.get_first_row <<-SQL
          SELECT #{columns.join ","} FROM #{table}
          WHERE id = #{id};
        SQL

        init_object_from_row(row)
      end
   end

   def find_by(attribute, value)
     rows = connection.execute <<-SQL
       SELECT #{columns.join ","} FROM #{table}
       WHERE #{attribute} = #{BlocRecord::Utility.sql_strings(value)};
     SQL

     rows_to_array(rows)
   end

   def method_missing(method, *args)
     attrs = method.to_s
     attrs.slice!("find_by_")
     find_by(attrs, args[0])
   end


   def find_each(hash = {})
    rows = connection.execute <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      LIMIT #{hash[:batch_size]};
    SQL

    for row in rows_to_array(rows)
      yield(row)
    end
  end

  def find_in_batches(hash={})
    start = hash[:start]
    batch_size = hash[:batch_size]

    rows = connection.execute <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      LIMIT #{batch_size} OFFSET #{start};
    SQL

    yield(rows_to_array(rows))
  end


   def take(num=1)
     if num > 1
       rows = connection.execute <<-SQL
         SELECT #{columns.join ","} FROM #{table}
         ORDER BY random()
         LIMIT #{num};
       SQL

       rows_to_array(rows)
     else
       take_one
     end
   end

   def take_one
     row = connection.get_first_row <<-SQL
       SELECT #{columns.join ","} FROM #{table}
       ORDER BY random()
       LIMIT 1;
     SQL

     init_object_from_row(row)
   end

   def first
     row = connection.get_first_row <<-SQL
       SELECT #{columns.join ","} FROM #{table}
       ORDER BY id ASC LIMIT 1;
     SQL

     init_object_from_row(row)
   end

   def last
     row = connection.get_first_row <<-SQL
       SELECT #{columns.join ","} FROM #{table}
       ORDER BY id DESC LIMIT 1;
     SQL

     init_object_from_row(row)
   end

   def all
     rows = connection.execute <<-SQL
       SELECT #{columns.join ","} FROM #{table};
     SQL

     rows_to_array(rows)
   end

   private

   def init_object_from_row(row)
     if row
       data = Hash[columns.zip(row)]
       new(data)
     end
   end

   def rows_to_array(rows)
     rows.map { |row| new(Hash[columns.zip(row)]) }
   end
 end
