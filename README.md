# apipie-diff

Visual diff for comparing versions of [ApiPie](https://github.com/Apipie/apipie-rails) documentation.

## Installation

```
gem install apipie-diff
```

## Usage

Download json docs of two versions of an ApiPie documented API and compare them with `apipie-diff`.

```
Usage:
    apipie-diff [OPTIONS] FILE1 FILE2

Parameters:
    FILE1                         file with json export of apipie docs
    FILE2                         file with json export of another version of apipie docs

Options:
    --stats                       print statistics
    --no-color                    disable colors
    -h, --help                    print help
```

## Example

```
curl -k https://$VERSION_01_HOSTNAME/apidoc.json > api_0.1.json
curl -k https://$VERSION_01_HOSTNAME/apidoc.json > api_0.2.json
apipie-diff api_0.1.json api_0.2.json
```
