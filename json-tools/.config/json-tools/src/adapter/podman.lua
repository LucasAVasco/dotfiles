return function(command, args)
	table.insert(args, "--format=json")

	return command, args
end
