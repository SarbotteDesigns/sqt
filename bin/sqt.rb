#!/usr/bin/env ruby
# encoding: utf-8

# Sarbotte Quality Tool v1.0
# Copyright Sarbotte Designs
# Open Sarbotte License

require 'sqt'

options = {}
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
  filesProperties = SQT.sarbottePath(options[:path], options[:extension])
# Si le chemin vers un fichier est donné en option
elsif options[:file]
  filesProperties = SQT.sarbotteFile(options[:file])
# Si une url est donnée en option
elsif options[:url]
  filesProperties = SQT.sarbotteCurl(options[:url])
end

# Si on a pu calculer le sqi d'un ou plusieurs fichiers
unless filesProperties.empty?
  filesProperties.sort_by! { |a| a[:sqi] }
  SQT.printResults(filesProperties, options)
  SQT.writeResults(filesProperties, options) if options[:fileName]
end