module WebDAV

import HTTP
using EzXML
using Base.Filesystem: readdir, mkdir, isdir, isfile
using Base: open
using Base64
import Base: download

namespace = Dict("d" => "DAV:")

struct Server
    url
    headers
end

escape_no_slash(url) = join(HTTP.escapeuri.(split(url,'/')),'/')


"""
    server = WebDAV.Server(url,username,password)

`url` is for example https://server/remote.php/webdav for an NextCloud instance
"""
function Server(url::AbstractString,username::AbstractString,password::AbstractString)
    userinfo = username * ":" * password
    headers = [("Authorization", "Basic $(base64encode(userinfo))")]
    return Server(url,headers)
end

function upload(s::Server,stream::IOStream,remotepath::AbstractString)
    remotepath_escaped = escape_no_slash(remotepath)
    r = HTTP.request("PUT", s.url * "/" * remotepath_escaped,s.headers, stream);
end

function upload(s::Server,localpath::AbstractString,remotepath::AbstractString)
    open(localpath) do stream
        upload(s,stream,remotepath)
    end
end

function download(s::Server,remotepath::AbstractString,localpath::AbstractString)
    open(localpath,"w") do file
        open(s,remotepath,"r") do stream
            while !eof(stream)
                write(file,readavailable(stream))
            end
        end
    end
end

function download(s::Server,remotepath::AbstractString)
    localpath = tempname()
    download(s,remotepath,localpath)
    return localpath
end

# Filesystem-like API


function Base.open(s::Server,remotepath::AbstractString,
                   mode::AbstractString = "r")

    remotepath_escaped = escape_no_slash(remotepath)
    if mode == "r"
        io = Base.BufferStream()
        r = HTTP.request("GET", s.url * "/" * remotepath_escaped,s.headers,response_stream = io)
        return io
    else
        error("unsupported mode $(mode)")
    end

    return nothing
end

function Base.open(f::Function,s::Server,remotepath::AbstractString,
                   mode::AbstractString = "r")

    remotepath_escaped = s.url * "/" * escape_no_slash(remotepath)
    @debug "remotepath_escaped: $remotepath_escaped"
    if mode == "r"
        r = HTTP.open("GET", remotepath_escaped,s.headers) do io
            f(io)
        end
    elseif mode == "w"
        r = HTTP.open("PUT", remotepath_escaped,s.headers) do io
            f(io)
        end
    else
        error("unsupported mode $(mode)")
    end

    return nothing
end

function properties(s,dir)
    r = HTTP.request("PROPFIND", s.url * "/" * escape_no_slash(dir), s.headers; status_exception = false);

    body = String(r.body)
    if r.status == 404
        return nothing,r.status
    else
        return EzXML.parsexml(body),r.status
    end
end

function Base.Filesystem.readdir(s,dir::AbstractString=".")
    doc,status = properties(s,dir)
    if status == 404
        error("directory $(dir) not found on server $(s.url)")
    end

    path = HTTP.URI(s.url).path
    response = findall("d:response",root(doc),namespace)
    list = Vector{String}(undef,length(response))
    for i = 1:length(response)
        url = nodecontent(findfirst("d:href",response[i]))

        if startswith(url,path)
            list[i] = url[length(path)+1:end]
        else
            list[i] = url
        end
    end

    return HTTP.unescapeuri.(list)
end

function Base.Filesystem.mkdir(s,dir::AbstractString)
    r = HTTP.request("MKCOL", s.url * "/" * escape_no_slash(dir), s.headers);
    return nothing
end

"""
    rm(server::WebDAV.Server,path)

Removes the `path` on the WebDAV `server`.
"""
function Base.Filesystem.rm(s,dir::AbstractString)
    r = HTTP.request("DELETE", s.url * "/" * escape_no_slash(dir), s.headers);
    return nothing
end

function Base.Filesystem.isdir(s,dir::AbstractString)
    doc,status = properties(s,dir)

    # not found
    if status == 404
        return false
    end

    resourcetype = findall("d:response[1]/d:propstat/d:prop/d:resourcetype/*",root(doc),namespace)

    return "collection" in nodename.(resourcetype)
end


function Base.Filesystem.isfile(s,dir::AbstractString)
    doc,status = properties(s,dir)

    # not found
    if status == 404
        return false
    end

    resourcetype = findall("d:response[1]/d:propstat/d:prop/d:resourcetype/*",root(doc),namespace)

    return !("collection" in nodename.(resourcetype))
end

export download, upload
end # module
