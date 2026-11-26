pr = proc {|a=1,b=1,c=1,d=1,e=1,f=1,g=1,h=1,i=1,j=1| pr.call }
40.times do |k|
  eval((0...k).map { "v#{_1}=0;" }.join + "begin; pr.call; rescue SystemStackError => e; e.backtrace; end")
end
p :survived
