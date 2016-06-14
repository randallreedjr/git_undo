class GitManager
  def initialize(history_file)
    @history_file = history_file
    @command_list = []
  end

  def run
    get_commands
    if last_command
      puts "Last git command was: `#{last_command}`"
      undo_message(last_command)
    else
      puts "No git commands found!"
    end
  end

  def get_commands
    File.open(@history_file) do |file|
      file.each do |line|
        # find all git commands
        if /\Agit / =~ line
          @command_list << line.chomp
        end
      end
    end
  end

  def last_command
    @command_list.reverse.detect do |raw_command|
      command = parse_command(raw_command)[:action]
      GitReverser::VALID_COMMANDS.include?(command)
    end
  end

  def parse_command(command)
    tokens = command.split(' ')
    action = tokens[1]
    arguments = tokens[2..-1].join(' ')
    return { action: action, arguments: arguments }
  end

  def undo_command(action, arguments)
    reverser = GitReverser.new(arguments)

    case action
    when 'add'
      reverser.reverse_add
    when 'commit'
      reverser.reverse_commit
    when 'merge'
      reverser.reverse_merge
    when 'checkout','co'
      reverser.reverse_checkout
    when 'rebase'
      reverser.reverse_rebase
    end
  end

  def undo_message(command)
    command_hash = parse_command(command)
    undo = undo_command(command_hash[:action], command_hash[:arguments])
    if !undo
      puts "Sorry, I don't know how to undo that command"
    else
      puts "To undo, run `#{undo}`\nWould you like to automatically run this command now? (y/N)"
      option = gets.chomp.downcase
      if option == 'y'
        puts undo
        %x[ #{undo} ]
      end
    end
  end
end
