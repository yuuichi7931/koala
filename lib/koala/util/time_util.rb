module Koala
  module Util
    module TimeUtil
      def get_month_list(from, to, month_list=[])
        if month_list.count==0
          month_list.push from.strftime("%Y-%m")
          return get_month_list(from, to, month_list)
        end

        last_time = Time.parse(month_list.last + '-01')
        if (last_time < to)
          month_list.push from.strftime("%Y-%m")
          return get_month_list(from, to, month_list)
        else
          return month_list
        end
      end
    end
  end
end
