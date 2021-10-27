module Sellers::ProfileHelper
  def return_and_terms_duration
    ReturnAndTerm.durations.map {|k, v| [k.split('_').join(' '), k]}
  end
end
