#!/usr/bin/env ruby
# encoding: utf-8

require 'sqt'

options = {}
paths = []
filesProperties = []

# Définition des options du script
OptionParser.new do |opts|
  opts.banner = "Sarbotte Quality Tool"
  opts.separator "Utilisation : rb [options]"

  opts.on("-f", "--file FILE", "Fichier à sarbottiser.") do |f|
    options[:file] = f || ""
  end

  opts.on("-p", "--path [PATH]", "Répertoire à sarbottiser.") do |p|
    options[:path] = p || "."
  end

  opts.on("-e", "--extension [EXTENSION]", "Extension recherchée.") do |e|
    options[:extension] = e || ""
  end

  opts.on("-c", "--curl [URL]", "Curl.") do |u|
    options[:url] = u || ""
  end

   opts.on("-w", "--write [FILENAME]", "Écrit les résultats dans un fichier.") do |w|
    options[:fileName] = w || "Sarbotte Quality.txt"
  end

  opts.on("-h", "--help", "Affiche l'aide.") do
    puts opts
    exit
  end
end.parse!

# Si le chemin d'un répertoire est donné en option
if options[:path]
  paths = findFiles(options[:path], options[:extension])
end

# Si le chemin vers un fichier est donné en option
if options[:file]
  paths << options[:file]
end

# Si on a pu trouver des chemins de fichiers
unless paths.empty?
  paths.each do |path|
    file = File.read path
    filesProperties << buildResult(path, file)
  end
end

# Si une url est donnée en option
if options[:url]
  require 'curb'
  http = Curl.get(options[:url])
  file = http.body_str
  filesProperties << buildResult(options[:url], file)
end

# Si on a pu calculer le sqi d'un ou plusieurs fichiers
unless filesProperties.empty?
  filesProperties.sort_by! { |a| a[:sqi]}
  printResults(filesProperties, options)
  if options[:fileName]
    writeResults(filesProperties, options)
  end
end