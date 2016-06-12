class GitReverser
  attr_reader :arguments

  VALID_COMMANDS = ['add','commit','merge','checkout','co', 'rebase']

  def initialize(arguments)
    @arguments = arguments
  end

  def reverse_add
    "git reset #{arguments}"
  end

  def reverse_commit
    'git reset --soft HEAD~'
  end

  def reverse_merge
    'git reset --merge ORIG_HEAD'
  end

  def reverse_checkout
    undo_command = "git checkout -"
    if arguments.start_with?('-b')
      #also delete branch
      branch_name = arguments.split.last
      undo_command += " && git branch -D #{branch_name}"
    end
    undo_command
  end

  def reverse_rebase
    if !arguments.include?('-i')
      current_branch_command = 'git rev-parse --abbrev-ref HEAD'
      branch_name = %x[ #{current_branch_command} ].chomp

      fetch_old_state = "git checkout #{branch_name}@{1}"
      delete_branch = "git branch -D #{branch_name}"
      recreate_branch = "git checkout -b #{branch_name}"

      "#{fetch_old_state} && #{delete_branch} && #{recreate_branch}"
    end
  end
end
