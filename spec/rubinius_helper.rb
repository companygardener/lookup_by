require 'colored'

at_exit {
  def gems(files)
    files.map { |path| path[%r{(rubysl-.*)-\d[^/]+/}, 1] }.compact.uniq.sort
  end

  def gemlist(list)
    puts list.map { |gem| "gem '#{gem}'" }.join("\n")
  end

  def header(label, list)
    puts
    puts "# [#{list.size}] #{label}".yellow
  end

  def section(label, files)
    list = gems(files)

    header label, list
    gemlist list
  end

  files = $".grep /rubysl/

  if ENV["DEBUG"] == "2"
    header "Files", files
    puts files.sort.join("\n")
  end

  runtime  = files.grep %r{rubinius-[\d.]+/runtime/gems/}
  internal = files.grep %r{rubinius-[\d.]+/gems/gems/}
  external = files - runtime - internal
  overlap  = (gems(external) & gems(runtime)) | (gems(external) & gems(internal))

  section "Rubinius runtime",  runtime
  section "Rubinius internal", internal
  section "Rubygems",          external

  header "Overlapping", overlap
  gemlist overlap
}
