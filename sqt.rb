# encoding: utf-8

# Sarbotte Quality Tool v1.0
# Sarbotte Designs
# Open Sarbotte License

require 'optparse'
require 'nokogiri'

require 'colorize'
require 'win32console'

options = {}
paths = []
filesProperties = []

# Trouver des fichiers en fonction d'un chemin et d'une extension
def findFiles(path, extension)
  path.gsub!('\\', File::SEPARATOR)
  Dir["#{path}/**/*\.#{extension}"]
end

# Récupère le nombre de caractères dans les balises script et style d'un fichier
def getJsAndCssLength(file)
  xmlFile = Nokogiri::HTML(file)
  jsLength = xmlFile.search('//script').reduce(0) { |total, script| total + script.text.length }
  jsAndCssLength = xmlFile.search('//style').reduce(jsLength) { |total, style| total + style.text.length }
end

# Définit le Sarbotte Quality Index d'un fichier
def sarbotteQuality(jsAndCss, total)
  (1 - jsAndCss.to_f/total.to_f) * 100
end

# Affiche en console les résultats
def printResults(filesProperties, options)
  system ("cls")
  puts "\nSarbotte Quality Tool\n".colorize( :cyan )
  if options[:path] then
    puts "Chemin : " + options[:path] + "\n\n"
  end
  if filesProperties.size > 1 then
    average = filesProperties.reduce(0) { |total, fP| total + fP[:sqi] }.to_f / filesProperties.size
    print "Moyenne : "
    puts "#{'%.2f' % average}".colorize( average < 0.5 ? :red : average < 0.8 ? :yellow : :green )
    puts ""
  end
  puts "Fichiers : "
  filesProperties.each do |fP|
    sqi = fP[:sqi]
    print "  #{fP[:uri].gsub(options[:path] && options[:path] != "." ? options[:path] : "", "")} : "
    print "#{'%.2f' % fP[:sqi]}".colorize( sqi < 50 ? :red : sqi < 80 ? :yellow : :green )
    puts " (#{fP[:jsAndCssLength]}/#{fP[:totalLength]})"
  end
end

# Écrit dans un fichier les résultats
def writeResults(filesProperties, options)
  result = "Sarbotte Quality Tool\n\n"
  if options[:path] then
    result += "Chemin : " + options[:path] + "\n\n"
  end
  if filesProperties.size > 1 then
    average = filesProperties.reduce(0) { |total, fP| total + fP[:sqi] }.to_f / filesProperties.size
    result +=  "Moyenne : #{'%.2f' % average}\n\n"
  end
  result += "Fichiers : \n"
  filesProperties.each do |fP|
    sqi = fP[:sqi]
    result += "  #{fP[:uri].gsub(options[:path] && options[:path] != "." ? options[:path] : "", "")} : #{'%.2f' % fP[:sqi]} (#{fP[:jsAndCssLength]}/#{fP[:totalLength]})\n"
  end
  File.open(options[:fileName], 'w') {|f| f.write(result) }
end

# Construit l'objet qui sera affiché, en fonction de son uri et de son contenu
def buildResult(uri, file)
  fileProperties = {}
  fileProperties[:uri] = uri
  fileProperties[:totalLength] = file.length
  fileProperties[:jsAndCssLength] = getJsAndCssLength file
  fileProperties[:sqi] = sarbotteQuality(fileProperties[:jsAndCssLength], fileProperties[:totalLength])
  fileProperties
end

# Définition des options du script
OptionParser.new do |opts|
  opts.banner = "Sarbotte Quality Tool"
  opts.separator "Utilisation : sqt.rb [options]"

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