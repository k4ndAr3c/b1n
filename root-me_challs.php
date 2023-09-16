#!/usr/bin/env php
<?php

// challenge website, shouldn't be changed
$url = 'http://www.root-me.org';
// username to check challs for
$user = 'k4ndar3c';
// static list cause fuck parsing HTML
$categories = Array('App-Script', 'App-System', 'Cracking', 'Cryptanalysis', 'Forensic', 'Network', 'Programming', 'Realist', 'Steganography', 'Web-Client', 'Web-Server');
// haven't tested other langs but should work or might need a few tweaks
$lang = 'en';
// delay between each GET requests in micro-seconds
$delay = 10000000;
// number of challs output
$n = 30;
// save to this file if != NULL
$fileOutput = '/tmp/challs.txt';

// building challList as follow array([ChallName] => Array(validations => number of validations, categorie => 'name', valided => false));
$challList = Array();
foreach ($categories as $categorie)
{
  $fetchURL = $url.'/'.$lang.'/Challenges/'.$categorie;
  $ret = get($fetchURL, $delay);
  $regex = "#\/Challenges\/$categorie\/([^\"\#]+).+?Who[^>]+>([0-9]{1,}+).+?<td>(\d+)<\/td>#si";
  preg_match_all($regex, $ret, $matches);
  sleep(1);
  #print_r($matches);
  foreach ($matches[1] as $key => $chall)
  {
    $challList[$chall] = Array('validations' => $matches[2][$key], 'categorie' => $categorie, 'points' => $matches[3][$key], 'valided' => false);
  }
}
#print_r($challList);
// we need to get our ajax_env_var
$fetchURL = sprintf('%s/%s?inc=score&lang=%s', $url, $user, $lang);
$ret = get($fetchURL, $delay);
$regex = sprintf("#data-ajax-env='([^']+)' data-origin=\"%s\?inc=score#", $user);
preg_match($regex, $ret, $match);
$ajaxToken = $match[1];

// Now we are going to check user page to flip the valided step if needed
#$fetchURL = sprintf('%s/%s?inc=score&lang=%s&var_ajax=1&var_ajax_env=%s', $url, $user, $lang, urlencode($ajaxToken));
#$ret = get($fetchURL, $delay);
#print_r($ret);
foreach ($challList as $key => $chall)
{
  $regex = sprintf('#class=" (rouge|vert)".+?Challenges\/%s\/%s#', $chall['categorie'], $key);
  #$regex = sprintf('#class="(rouge|vert)".*?Challenges\/%s\/%s#', $chall['categorie'], $key);
  #printf('#class="(rouge|vert)"*Challenges\/%s\/%s#', $chall['categorie'], $key);
  
  if (preg_match($regex, $ret, $matches)) {
  #print_r($matches);
    if ($matches[1] == 'vert') {
      $challList[$key]['valided'] = true;
    }
  }
}

// Now our data is ready and we can do whatever we want with it
// Goal of this script is to tell the user which challenge he should do next according to valdations number
uasort($challList, 'sort_challs');
$i = 0;
echo "\n[*]   You should do the challs in this order:..   \n\n";
$content = '';
foreach ($challList as $key => $chall)
{
  #print_r($chall);
  if (!strpos($key, 'tri_co')){
  if ($chall['valided'] === false)
  {
    $output = sprintf("\033[94m[%s] \033[0m%s has \033[92m%d \033[0mvalidations \033[31m[%d points]\033[0m\n", $chall['categorie'], $key, $chall['validations'], $chall['points']);
    $content .= $output;
    echo $output;
    $i++;
  }
  if ($i == $n) break;
}}
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
  static $ch = null;

  if ($ch === null)
      $ch = curl_init();
  curl_setopt($ch, CURLOPT_URL, $url);
  curl_setopt($ch, CURLOPT_HEADER, true);
  curl_setopt($ch, CURLOPT_FOLLOWLOCATION, 1);
  curl_setopt($ch, CURLOPT_FORBID_REUSE, false);
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

  return $body;
}
