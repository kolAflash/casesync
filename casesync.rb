#!/usr/bin/ruby

require 'find'

DEBUG = false



def main(argv)
	do_it, rename_left, root_left, root_right = parse_argv(argv)
	for left_p in Find.find(root_left) do
		left_p_short = cut_root(left_p, root_left)
		if left_p_short != ''
			puts("cheking:     left: #{left_p_short}") if DEBUG
			dir_short = cut_root(File.dirname(left_p), root_left)
			right_dir = sync_case(root_right, dir_short)
			
			if File.directory?(right_dir)
				for right_name in Dir.entries(right_dir) do
					if ! ['.', '..'].include?(right_name)
						left_name = File.basename(left_p)
						if left_name.downcase == right_name.downcase
							right_p_short = dir_short == '' ? right_name : File.join(dir_short, right_name)
							puts("            right: #{right_p_short}") if DEBUG
							if left_name != right_name
								right_p = File.join(root_right, right_p_short)
								rename_by_template(left_p, right_p, do_it, rename_left, root_left, root_right)
							end
						end
					end
				end
			end
			
		end
	end
	return 0
end


def rename_by_template(left_path, right_path, do_it, rename_left, root_left, root_right)
	template_path = left_path
	target_path = right_path
	target_root = root_right
	if rename_left
		template_path = right_path
		target_path = left_path
		target_root = root_left
	end
	target_dir = File.dirname(target_path)
	template_name = File.basename(template_path)
	target_new_path = File.join(target_dir, template_name)
	target_new_path_short = cut_root(target_new_path, target_root)
	if File.exists?(target_new_path)
		puts("            error, object exists: #{target_new_path_short}")
	else
		target_path_short = cut_root(target_path, target_root)
		puts("         renaming: #{target_path_short} => #{target_new_path_short}")
		File.rename(target_path, target_new_path) if do_it
	end
end


def sync_case(root, cased_dir)
	cased_dir_ary = []
	basename = File.basename(cased_dir)
	while basename != '.'
		cased_dir_ary << basename
		cased_dir = File.dirname(cased_dir)
		basename = File.basename(cased_dir)
	end
	
	dir = root
	for sub in cased_dir_ary.reverse
		found_identical = false
		found_with_different_case = nil
		if File.directory?(dir)
			for entry in Dir.entries(dir) do
				if sub == entry
					found_identical = true
				elsif sub.downcase == entry.downcase
					found_with_different_case = entry
				end
			end
		end
		if found_identical || !found_with_different_case
			dir = File.join(dir, sub)
		else
			dir = File.join(dir, found_with_different_case)
		end
	end
	return dir
end


def parse_argv(argv)
	do_it = false
	rename_left = false
	
	next_arg = 0
	
	in_options = true
	while in_options do
		if argv[next_arg] == '--do-it'
			do_it = true
			next_arg += 1
		elsif argv[next_arg] == '--rename-left'
			rename_left = true
			next_arg += 1
		else
			in_options = false
		end
	end
	
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
					"--do-it\n"+
					"        Really rename stuff. Else needed renames will only be printed."+
					"\n"+
					"--rename-left\n"+
					"        Rename files in the left directory. Default is to rename in the right directory."
				)
		exit(1)
	end
	return do_it, rename_left, root_left, root_right
end


def cut_root(path, root)
	root = root[0...-1] if root[-1] == '/'
	result = path[root.length..-1]
	result = result[1..-1] if result[0] == '/'
	return result
end


exit(main(ARGV))
