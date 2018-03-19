#!/usr/bin/ruby

require 'find'

DEBUG = true



def main(argv)
	rename_left, root_left, root_right = options(argv)
	for left_p in Find.find(root_left) do
		left_p_short = cut_root(left_p, root_left)
		if left_p_short != ''
			puts("cheking:     left: #{left_p_short}") if DEBUG
			dir_short = cut_root(File.dirname(left_p), root_left)
			right_dir = File.join(root_right, dir_short)
			
			if File.directory?(right_dir)
				for right_name in Dir.entries(right_dir) do
					if ! ['.', '..'].include?(right_name)
						left_name = File.basename(left_p)
						if left_name.downcase == right_name.downcase
							right_p_short = dir_short == '' ? right_name : File.join(dir_short, right_name)
							puts("            right: #{right_p_short}") if DEBUG
							if left_name != right_name
								right_p = File.join(root_right, right_p_short)
								rename_by_template(left_p, right_p, rename_left)
							end
						end
					end
				end
			end
			
		end
	end
	return 0
end


def rename_by_template(left_path, right_path, rename_left)
	template_path = left_path
	target_path = right_path
	if rename_left
		template_path = right_path
		target_path = left_path
	end
	target_dir = File.dirname(target_path)
	template_name = File.basename(template_path)
	puts("         renaming: #{target_path} => #{File.join(target_dir, template_name)}")
	File.rename(target_path, File.join(target_dir, template_name))
end


def options(argv)
	next_arg = 0
	
	rename_left = argv[next_arg] == '--rename-left'
	next_arg += 1 if rename_left
	
	next_arg += 1 if argv[next_arg] == '--'
	
	root_left = argv[next_arg]
	next_arg += 1
	
	root_right = argv[next_arg]
	next_arg += 1
	
	if !root_left || !root_right
		puts(
					"Usage: casesync.rb [--rename-left] [--] LEFT RIGHT\n"+
					"\n"+
					"Searches trough the LEFT directory tree and syncronizes the case of\n"+
					"the file and directory names in the RIGHT tree."+
					"\n"+
					"--rename-left\n"+
					"        Rename files in the left directory. Default is to rename in the right directory."
				)
		exit(1)
	end
	return rename_left, root_left, root_right
end


def cut_root(path, root)
	root = root[0...-1] if root[-1] == '/'
	result = path[root.length..-1]
	result = result[1..-1] if result[0] == '/'
	return result
end


exit(main(ARGV))
