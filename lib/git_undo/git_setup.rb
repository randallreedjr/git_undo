class GitSetup

  attr_reader :file

  def initialize
    @file = nil
  end

  def run
    puts "It looks like you haven't run the initial setup. Would you like to do so now? (y/N)"
    if gets.chomp.downcase == 'y'
      puts "This will involve appending an alias to your .bash_profile. Okay to proceed? (y/N)"
      if gets.chomp.downcase == 'y'
        puts "Thanks!"
        update_bash_profile
      else
        puts "Goodbye!"
      end
    else
      puts "Goodbye!"
    end
  end

  def update_bash_profile
    @file = File.open(File.expand_path('~' + '/.bash_profile'),'r+')

    unless alias_exists?
      write_to_bash_profile
      puts "Please run `source ~/.bash_profile && cd .` to reload configuration"
    end
    file.close
  end

  def alias_exists?
    alias_exists = false

    file.readlines.each do |line|
      if /\A[\s]*alias/.match line
        if /\A[\s]*alias gitundo="HISTFILE=\$HISTFILE gitundo"\n\z/.match line
          alias_exists = true
        end
      end
    end

    return alias_exists
  end

  def write_to_bash_profile
    file.write("# Git Undo\n")
    file.write("alias git-undo=\"HISTFILE=$HISTFILE git-undo\"\n")
    file.write("# Flush history immediately")
    file.write("export PROMPT_COMMAND='history -a")
  end
end
