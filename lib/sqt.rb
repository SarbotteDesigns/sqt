﻿# encoding: utf-8

# Sarbotte Quality Tool v1.0
# Copyright Sarbotte Designs
# Open Sarbotte License

module SQT

  require 'optparse'
  require 'nokogiri'

  require 'colorize'
  require 'uri'

  class Sqt

    # Construit l'objet qui sera affiché, en fonction de son uri et de son contenu
    def self.buildResult(uri, file)
      fileProperties = {}
      fileProperties[:uri] = uri
      fileProperties[:totalLength] = file.bytesize
      fileProperties[:jsAndCssLength] = getJsAndCssLength file
      fileProperties[:sqi] = sarbotteQuality(fileProperties[:jsAndCssLength], fileProperties[:totalLength])
      fileProperties
    end

    # Récupère le nombre de caractères dans les balises script et style d'un fichier
    def self.getJsAndCssLength(file)
      xmlFile = Nokogiri::HTML(file)
      jsLength = xmlFile.search('//script').reduce(0) { |total, script| total + script.text.bytesize }
      xmlFile.search('//style').reduce(jsLength) { |total, style| total + style.text.bytesize }
    end

    # Définit le Sarbotte Quality Index d'un fichier
    def self.sarbotteQuality(jsAndCss, total)
      (1 - jsAndCss.to_f/total.to_f) * 100
    end

    # Curl with depth
    def self.sarbotteCurlWithDepth(url, depth, result)
      urlUrl = URI(url)
      http = Curl.get(url)
      file = http.body_str
      xmlFile = Nokogiri::HTML(file)
      allowedScheme = ['http', 'https']
      if !(result.any? {|sqr| URI(sqr[:uri]).path.gsub(/\/$/, '') == urlUrl.path.gsub(/\/$/, '') })
        result.push Sqt.buildResult(url, file)
      end
      if depth > 0
        xmlFile.search('//a').each do |foundLink|
          begin
            if foundLink['href'] =~ /^\//
              toVisit = url.gsub(/\/$/, '') + foundLink['href']
            else
              toVisit = foundLink['href']
            end
            puts toVisit
            if !(toVisit =~ /^\s*$/)
              toVisitUrl = URI(toVisit)
              result.any? do |sqr| 
                URI(sqr[:uri]).path.gsub(/\/$/, '') == toVisitUrl.path.gsub(/\/$/, '')
              end
              if urlUrl.host == toVisitUrl.host && allowedScheme.include?(toVisitUrl.scheme) && !result.any? { |sqr| URI(sqr[:uri]).path.gsub(/\/$/, '') == toVisitUrl.path.gsub(/\/$/, '') }
                d = sarbotteCurlWithDepth(toVisit, depth - 1, result)
                result = d if !d.nil?
              end
            end
          rescue
            puts "exception"
          end
        end
      end

      result
      
    end

  end

  def self.sarbottePath(path, extension)
    path.gsub!('\\', File::SEPARATOR)
    Dir["#{path}/**/*\.#{extension}"].map{ |p| Sqt.buildResult(p, File.read(p))}
  end

  def self.sarbotteFile(file)
    Sqt.buildResult(file, File.read(file))
  end

  def self.sarbotteString(string)
    Sqt.buildResult("", string)
  end

  def self.sarbotteCurl(url, depth)
    require 'curb'
    result = []
    if depth.nil?
      http = Curl.get(url)
      file = http.body_str
      result = Sqt.buildResult(url, file)
    else
      result = Sqt.sarbotteCurlWithDepth(url, depth, [])
    end
    return result
  end

   # Affiche en console les résultats
  def self.sarbottePrint(filesProperties, options)
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
  def self.sarbotteWrite(filesProperties, options)
    result = "Sarbotte Quality Tool\n\n"
    if options[:path] then
      result += "Chemin : " + options[:path] + "\n\n"
    end
    if filesProperties.size > 1 then
      average = filesProperties.reduce(0) { |total, fP| total + fP[:sqi] }.to_f / filesProperties.size
      result +=  "Moyenne : "
      result += "#{'%.2f' % average}\n\n"
    end
    result += "Fichiers : \n"
    filesProperties.each do |fP|
      sqi = fP[:sqi]
      result += "  #{fP[:uri].gsub(options[:path] && options[:path] != "." ? options[:path] : "", "")} : "
      result += "#{'%.2f' % fP[:sqi]}"
      result += "(#{fP[:jsAndCssLength]}/#{fP[:totalLength]})\n"
    end
    File.open(options[:fileName], 'w') {|f| f.write(result) }
  end

end
