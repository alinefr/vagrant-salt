<?php
if (!extension_loaded('curl')){
    error_log("Missing PHP cURL!", 0);
    return False;
} elseif (!extension_loaded('dom')){
    error_log("Missing PHP DOM!", 0);
    return False;
}

$page = curl_init("http://br.wordpress.org/latest");
curl_setopt($page, CURLOPT_RETURNTRANSFER, true);
curl_setopt($page, CURLOPT_BINARYTRANSFER, true);

$content = curl_exec($page);
curl_close($page);

libxml_use_internal_errors(true);
$html = new DOMDocument();
$html->loadHTML($content);

$xpath = new DOMXPath($html);

$tags = $xpath->query('//div[@class="sidebar"]/p[@class="download-tar"]/a[@href]');
foreach($tags as $tag){
    $url = $tag->getAttribute('href');
    preg_match('/\d+(?:\.\d+)+/', $url, $matches);
    echo $matches[0] . "\n";
}

