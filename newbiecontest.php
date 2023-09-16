#!/usr/bin/env php
<?php

// challenge website, shouldn't be changed
$url = 'https://www.newbiecontest.org';
// userId to check challs for
$user = 79413;
// delay between each GET requests in micro-seconds, useless on this website
$delay = 500000;
// number of challs output
$n = 15;
// save to this file if != NULL
$fileOutput = '/tmp/n3wb-challs.txt';

// building challList as follow array([ChallName] => Array(validations => number of validations, categorie => 'name', valided => false));
$challList = Array();
$fetchURL = $url.'/index.php?page=info_membre&id='.$user;
$ret = get($fetchURL, $delay);
$ret = html_entity_decode($ret);
$regex = "#index\.php\?page=epreuve&no=(\d+)[^>]+>([^<]+).+?(\d+) validation.+?images\/(valide|nonvalide)#si";
preg_match_all($regex, $ret, $matches);
// matches array 1 -> challId, 2 -> challName, 3 -> challValidations, 4 -> valided or not
foreach ($matches[1] as $key => $chall)
{
    // we don't store twice the same chall
    // challList will be indexed by challId
    if (array_key_exists($chall, $challList)) continue;
    $challList[$chall] = Array('validations' => $matches[3][$key], 'chall' => str_replace('\\', '', trim($matches[2][$key])), 'valided' => $matches[4][$key] == 'valide' ? true : false);
}

// Now our data is ready and we can do whatever we want with it
// Goal of this script is to tell the user which challenge he should do next according to valdations number
uasort($challList, 'sort_challs');
$i = 0;
echo "You should do the challs in this order...\n";
$content = '';
foreach ($challList as $key => $chall)
{
    if ($chall['valided'] === false)
    {
        $output = sprintf("[%d] %s has %d validations\n", $key, $chall['chall'], $chall['validations']);
        $content .= $output;
        echo $output;
        $i++;
    }
    if ($i == $n) break;
}
if ($fileOutput != NULL)
{
    file_put_contents($fileOutput, $content);
}

// Function to sort the challList array, no checks are being made
function sort_challs($a, $b)
{
    return $a['validations'] < $b['validations'];
}

function get($url, $delay = null)
{
    static $lastRequestTime = 0;

    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_HEADER, true);
    curl_setopt($ch, CURLOPT_FOLLOWLOCATION, 1);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
    if ($delay)
    {
        $timeElapsed = microtime(true) - $lastRequestTime;
        if ($timeElapsed < $delay && $lastRequestTime != 0) usleep($delay - $timeElapsed);
        $lastRequestTime = microtime(true);
    }
    echo "Getting $url...";
    $response = curl_exec($ch);
    $header_size = curl_getinfo($ch, CURLINFO_HEADER_SIZE);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    echo " returned $httpCode\n";
    $header = substr($response, 0, $header_size);
    $body = substr($response, $header_size);
    curl_close($ch);

    return $body;
}
