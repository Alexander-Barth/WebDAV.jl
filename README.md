# PkgTemplates

<!-- [![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://alexander-barth.github.io/WebDAV.jl/stable)
[![Latest](https://img.shields.io/badge/docs-latest-blue.svg)](https://alexander-barth.github.io/WebDAV.jl/latest) -->
[![Build Status](https://travis-ci.org/Alexander-Barth/WebDAV.jl.svg?branch=master)](https://travis-ci.org/Alexander-Barth/WebDAV.jl)
[![Build Status Windows](https://ci.appveyor.com/api/projects/status/github/Alexander-Barth/WebDAV.jl?branch=master&svg=true)](https://ci.appveyor.com/project/Alexander-Barth/webdav-jl)
[![Codecov](https://codecov.io/gh/Alexander-Barth/WebDAV.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/Alexander-Barth/WebDAV.jl)

WebDAV.jl is an experimental WebDAV client for Julia

## Installation

```julia
using Pkg
Pkg.add("WebDAV")
```

## Usage

```julia
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
```
