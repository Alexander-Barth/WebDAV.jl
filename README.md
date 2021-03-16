# WebDAV.jl

<!-- [![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://alexander-barth.github.io/WebDAV.jl/stable)
[![Latest](https://img.shields.io/badge/docs-latest-blue.svg)](https://alexander-barth.github.io/WebDAV.jl/latest) -->
[![Build Status](https://github.com/Alexander-Barth/WebDAV.jl/workflows/CI/badge.svg)](https://github.com/Alexander-Barth/WebDAV.jl/actions)
[![Codecov](https://codecov.io/gh/Alexander-Barth/WebDAV.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/Alexander-Barth/WebDAV.jl)

WebDAV.jl is an experimental WebDAV client for Julia

## Installation

```julia
using Pkg
Pkg.add(PackageSpec(url="https://github.com/Alexander-Barth/WebDAV.jl",rev="master"))
```

## Usage


The functions `download` and `upload` are used to interact with a WebDAV server.

```julia
using WebDAV

username = "user"
password = "abc123"
url =  "https://example.com/remote.php/webdav"

s = WebDAV.Server(url,username,password);

fname = "local_file.txt"
remote_fname = "remote_file.txt"

# upload a file to a WebDAV server
r = upload(s, fname, remote_fname)


# download file form a WebDAV server
fname2 = "local_file2.txt"
download(s, remote_fname, fname2)

# list all files and directory under a directory
file_list = readdir(s,"/")

# checks if a file "foo.txt" exists
isfile(s,"foo.txt")

# checks if a directory "dir" exists
isdir(s,"dir")
```
