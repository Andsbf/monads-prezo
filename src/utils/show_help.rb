ShowHelp = -> (msg) {
  if ENV['SHOW_HELP'] == 'TRUE'|| 'true'
    puts msg
  end
}
