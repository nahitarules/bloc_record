module BlocRecord
   class Collection < Array
     def update_all(updates)
       ids = self.map(&:id)
       self.any? ? self.first.class.update(ids, updates) : false
     end

     def take(num=1)
      if num > 1
        self[0..(num-1)]
      else
        self.first
      end
    end

    def where(*args)
      if args.count > 1
        expression = args.shift
        params = args
      else
        case args.first
        when String
          expression = args.first
        when Hash
          expression_hash = BlocRecord::Utility.convert_keys(args.first)
          expression = expression_hash.map { |key, value| "#{key} = #{BlocRecord::Utility.sql_strings(value)}"}.join(" AND ")
        end
      end

      self.any? ? self.first.class.where(expression) : false
    end

    def not(*args)
      self.any? ? self.first.class.not(*args) : false
    end
   end
 end
