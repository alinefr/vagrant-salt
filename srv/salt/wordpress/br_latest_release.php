<?php
/* Copyright 2014, Aline Freitas <aline@alinefreitas.com.br>
 * 
 * This script uses a international locale code as stdin and 
 * returns latest version number for the especified locale.
 * Unfortunately wpcentral.io/internacionalization gives the 
 * wrong page for Brazilian Portuguese locale (pt_BR), so we provide
 * the right page hardcoded here.
 */

// Make sure we have cURL and DOM php extensions
if (!extension_loaded('curl')){
    error_log("Missing PHP cURL!", 0);
    return False;
} elseif (!extension_loaded('dom')){
    error_log("Missing PHP DOM!", 0);
    return False;
}

// Check command line for argument
if (empty($argv[1])) {
    error_log("Usage: " . $argv[0] . " locale");
    return False;
}

// Initial variables assignment
$locale = $argv[1];
$url = "";

// pt_BR locale is irregular, so we provide the URL here!
if($locale == "pt_BR"){
    $url = 'http://br.wordpress.org';
} else{
    // For any other one we get the URL from WP website
    $intpage = curl_init("http://wpcentral.io/internationalization");
    curl_setopt($intpage, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($intpage, CURLOPT_FOLLOWLOCATION, true);

    $content = curl_exec($intpage);
    curl_close($intpage);

    libxml_use_internal_errors(true);
    $inthtml = new DOMDocument();
    $inthtml->loadHTML($content);

    $xpath = new DOMXPath($inthtml);

    $inttags = $xpath->query('//div[@class="col-sm-6"]');
    foreach($inttags as $inttag){
        $localetext = $inttag->nodeValue;
        foreach($inttag->childNodes as $item){
            $localeurl = $item->getAttribute('href');
            if (!empty($localeurl)){
                if(preg_match("~\b" . $locale . "\b~",$localetext)){
                    $url = $localeurl;
                }
            }
        }
    }
}

if(empty($url)){
    error_log("Could not find url for " . $locale);
    return False;
}

$page = curl_init($url . "/latest/");
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
    $country_url = $tag->getAttribute('href');
    preg_match('/\d+(?:\.\d+)+/', $country_url, $matches);
    echo $matches[0] . "\n";
}

