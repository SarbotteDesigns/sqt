# Sarbotte Quality Tool [![Gem Version](https://badge.fury.io/rb/sqt.png)](http://badge.fury.io/rb/sqt) [![Build Status](https://travis-ci.org/SarbotteDesigns/sqt.png)](https://travis-ci.org/SarbotteDesigns/sqt)

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
$ sqt [options]
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
$ sqt -p . -e html
```

## Installation

Installer ruby.

Installer sqt :

```bash
$ gem install sqt
```

## License

Open Sarbotte License
