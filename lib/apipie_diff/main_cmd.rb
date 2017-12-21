require 'json'
require 'yaml'
require 'diffy'
require 'colorize'
require 'clamp'
require 'apipie_diff/normalizer'

module ApipieDiff
  class MainCmd < Clamp::Command
    option '--stats', :flag, 'print statistics'
    option '--no-color', :flag, 'disable colors', :attribute_name => :disable_colors
    parameter 'FILE1', 'file with json export of apipie docs', :attribute_name => :left_file_path
    parameter 'FILE2', 'file with json export of another version of apipie docs', :attribute_name => :right_file_path

    def execute
      right_resources = normalize_docs(left_file_path, load_doc(left_file_path))
      left_resources = normalize_docs(right_file_path, load_doc(right_file_path))

      actions_stats = print_diff(left_resources, right_resources)
      print_stats(left_resources, right_resources, actions_stats) if stats?
      return 0
    end

    private

    def print_diff(left_resources, right_resources)
      actions_stats = {
        :new => [],
        :removed => [],
        :changed => []
      }

      resource_names = right_resources.keys | left_resources.keys
      resource_names.sort.each do |res|
        if !right_resources.has_key? res
          heading('#', res, colorize('REMOVED', :red))

        else
          if !left_resources.has_key? res
            heading('#', res, colorize('NEW', :green))

            left_methods = {}
            right_methods = right_resources[res]['methods']
          else
            heading('#', res)

            left_methods = left_resources[res]['methods']
            right_methods = right_resources[res]['methods']
          end

          method_names = left_methods.keys | right_methods.keys
          method_names.sort.each do |m|

            if !right_methods.has_key? m
              heading('  *', m, colorize('REMOVED', :red))
              actions_stats[:removed] << [res, m]

            elsif !left_methods.has_key? m
              diff = diff_method(left_methods[m], right_methods[m])
              heading('  *', m, colorize('NEW', :green))
              actions_stats[:new] << [res, m]

              puts_diff(diff, ' '*6) if diff.strip != ''
            else
              diff = diff_method(left_methods[m], right_methods[m])

              if diff.strip != ''
                heading('  *', m, colorize('CHANGED', :yellow))
                actions_stats[:changed] << [res, m]

                puts_diff(diff, ' '*6)
              else
                heading('  *', m)
              end
            end
          end
        end
      end
      actions_stats
    end

    def print_stats(left_resources, right_resources, actions_stats)
      puts
      puts '-'*80

      added_resources = right_resources.keys - left_resources.keys
      removed_resources = left_resources.keys - right_resources.keys

      puts colorize("#{added_resources.size} added resources:", :green)
      puts "    #{added_resources.join("\n    ")}"

      puts colorize("#{removed_resources.size} removed resources:", :red)
      puts "    #{removed_resources.join("\n    ")}"

      puts colorize("#{actions_stats[:new].size} new actions:", :green)
      puts "    #{actions_stats[:new].map{|m| m.join(' # ') }.join("\n    ")}"

      puts colorize("#{actions_stats[:changed].size} changed actions:", :yellow)
      puts "    #{actions_stats[:changed].map{|m| m.join(' # ') }.join("\n    ")}"
      puts
    end

    def load_doc(file)
      JSON.load(File.read(file))
    rescue JSON::ParserError => e
      signal_usage_error("#{file} doesn't seem to be valid json file:\n#{e}")
    rescue Errno::ENOENT => e
      signal_usage_error("Couldn't read #{file}:\n#{e}")
    end

    def normalize_docs(file, docs)
      ApipieDiff::Normalizer.new.normalize(docs)
    rescue RuntimeError => e
      signal_usage_error("Couldn't process #{file}:\n#{e}")
    end

    def heading(prefix, name, note = nil)
      puts "#{prefix} #{name}" + (note.nil? ? '' : " (#{note})")
    end

    def diff_method(left_method, right_method)
      left_dump = left_method.nil? ? '' : YAML.dump(left_method)
      right_dump = right_method.nil? ? '' : YAML.dump(right_method)
      Diffy::Diff.new(left_dump, right_dump).to_s
    end

    def puts_diff(diff, indent = '')
      diff.split("\n").each do |line|
        if line[0] == '+'
          puts indent + colorize(line, :green)
        elsif line[0] == '-'
          puts indent + colorize(line, :red)
        else
          puts indent + line
        end
      end
    end

    def colorize(str, color_name)
      if disable_colors?
        str
      else
        str.colorize(color_name)
      end
    end
  end
end
