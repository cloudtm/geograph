task :mytest, :arg1 do |t, args|
  puts "This is a test task, I got the arg1 as #{args[:arg1]}"
end
