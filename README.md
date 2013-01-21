# Sarbotte Quality Tool

Le Sarbotte Quality Tool est l'outil de référence pour s'assurer de la qualité des développements côté client. Il permet de mesurer la quantité de code javascript ou css présent dans une page et à externaliser (quand possible).

La quête de la qualité absolue peut se faire sur différents types de fichiers, pour peu que ceux-ci aient une syntaxe xml :
* html
* jsp
* ftl
* ...

Il est également possible de lancer le sqt sur une page html distante.

## Utilisation

Utilisation :
```bash
$ ruby sqt.rb [options]
```

Options disponibles :

    -f, --file FILE                  Fichier à sarbottiser.
    -p, --path [PATH]                Répertoire à sarbottiser.
    -e, --extension [EXTENSION]      Extension recherchée.
    -c, --curl URL                   Curl.
    -w, --write [FILENAME]           Écris les résultats dans un fichier.
    -h, --help                       Affiche l'aide.

Exemple : 
```bash
$ ruby sqt.rb -p . -e html
```

## Installation

Cloner sqt :

```bash
$ git clone https://github.com/SarbotteDesigns/sqt.git
$ cd sqt
```

Installer ruby.

Installer la gem bundle :

```bash
$ gem install bundle
```

Installer les dépendances de sqt :

```bash
$ bundle install
```

## License

Open Sarbotte License

   
