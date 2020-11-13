require 'cli-tree'
require 'date'

suffixname = '_file_listing'
suffix = suffixname+'.html'
tmpdirectory = './subject-trees/'

notice='
<div class="card bg-warning mb-3">
    <div class="card-body" style="text-align: center;">
        <h2><b>Notice</b></h2>

        This is <b>NOT</b> the archive! The main archive page contains features such as easy browsing of files and bulk downloading. This is a listing of files for a particular subject. <br>
        To visit the archive follow the link.

        <h3><a href="https://atar-wace-archive.github.io" class="card-link" title="🔗MAIN ARCHIVE">---->    🔗Click here to access the archive🔗    <----</a></h3>
        <h3><a href="https://github.com/atar-wace-archive/atar-wace-archive" class="card-link" title="🔗Github source">Source code</a></h3>

        <b>⚠️NOTE</b>: If file has "error", then the file is not archived, you cannot access it :(
    </div>
</div>'

subjects = Array.new
urls = Array.new
today = Date.today.strftime("%Y-%m-%d")

system("mkdir -p '"+tmpdirectory+"'; jq -c 'walk(if type == \"object\" then if has(\"text\") then .name=.text|del(.text) else . end | try del(.state) | if has(\"url\") then .children=[.type,.url,(.name|gsub(\"[_-]\";\" \")|gsub(\"%20\";\" \"))]|del(.type,.url) else . end else . end) | .[][]|try .[]' ALL/root.json > './__noooot__.json'")

File.readlines('./__noooot__.json').each do |line|
    tree = TreeNode.from_json(line).render
    subjects << '<a href="https://atar-wace-archive.github.io/list/'+tree[0]+suffix+'" title="'+tree[0]+'">'+tree[0]+"</a>"
    urls << 'https://atar-wace-archive.github.io/list/'+tree[0]+suffixname

    File.open(tmpdirectory+tree[0]+suffix, 'w') do |file|
        file.puts '
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>📝 ATAR/WACE archive - '+tree[0].upcase+' past papers listing</title>
	<meta name="description" content="File listing for subject '+tree[0].upcase+'. Contains papers from the current system and rare Stage 3 (3A/3B AND 3C/3D) papers from the old system.">
    <style>
		body { max-width:100%; min-width:300px; margin:0 auto; padding:20px 10px; font-size:14px; font-size:1.4em; }
    </style>
</head>

<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" integrity="sha384-JcKb8q3iqJ61gNV9KGb8thSsNjpSL0n8PARn9HuZOnIxN0hoP+VmmDGMN5t9UJ0Z" crossorigin="anonymous">

<body>
<h1>list of files for subject '+tree[0].upcase+'</h1><br>
'+notice+'

<div class="card">
<div class="card-body">
<tt>
<pre>
<a href="https://atar-wace-archive.github.io/list" class="card-link" title="..">..</a>
'
        for line in tree
            file.puts line+"\n"
        end
        file.puts '
</tt>
</div>
</div>
</body>'
    end
end

system("rm ./__noooot__.json") # Dont know if rm is a good idea?? wht do i know..

File.open(tmpdirectory+'/index.html', 'w') do |file|
    file.puts '
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>📝 ATAR/WACE archive - past papers listing</title>
	<meta name="description" content="Free archive of past papers/past exams for every atar/wace course. We have papers from the current system and rare Stage 3 (3A/3B AND 3C/3D) papers from the old system.">
    <style>
        body { max-width:100%; min-width:300px; margin:0 auto; padding:20px 10px; font-size:14px; font-size:1.4em; }
    </style>
</head>

<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" integrity="sha384-JcKb8q3iqJ61gNV9KGb8thSsNjpSL0n8PARn9HuZOnIxN0hoP+VmmDGMN5t9UJ0Z" crossorigin="anonymous">

<body>
<h1>list of files</h1>
'+notice+'
<div class="card bg-info mb-3">
    <div class="card-body">
    <pre>
        SUBJECT LISTING FORMAT EXAMPLE:
    <tt>
        [subject]
        ├── [year]
        ├── 2010
        |   ├── [file name]
        |   |   ├── [type] ⚠️NOTE: Error => File is not archived, you cannot access it :(
        |   |   ├── [file URL]
        |   |   └── [Human-readable/SEO name] For search engine purposes - _,-,%20 all substituted with space.</pre></tt>
    </div>
</div>

<div class="card">
<div class="card-body">
<tt>
<pre>
'
    root_tree = TreeNode.from_json(
        {name:"ROOT",children:subjects}.to_json  
    ).render


    for line in root_tree
        file.puts line+"\n"
    end
    file.puts '
</tt>
</div>
</div>
</body>'
end

File.open(tmpdirectory+'/sitemap.xml', 'w') do |file|
    file.puts '<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
    <url>
        <loc>https://atar-wace-archive.github.io/list</loc>
        <lastmod>'+today+'</lastmod>
    </url>
'

    for url in urls
    file.puts '    <url>
        <loc>'+url+'</loc>
        <lastmod>'+today+'</lastmod>
    </url>'
    end

    file.puts '</urlset>'
end

system('cp -r "'+tmpdirectory+'." ../atar-wace-archive/list')