function ssd-price
  set amzn (curl -s 'https://www.amazon.in/Crucial-BX500-240GB-2-5-inch-CT240BX500SSD1/dp/B07G3YNLJB/ref=mp_s_a_1_3?dchild=1&keywords=ssd&qid=1634231023&qsid=257-272
4214-9903254&sr=8-3&sres=B07G3YNLJB%2CB07KCGPRMQ%2CB076Y374ZH%2CB089QXQ1TV%2CB08FJB98F1%2CB07YFF3JCN%2CB078WYS5K6%2CB07WFNQ9JF%2CB093V4NHV5%2CB079T8BZMG%2CB07HCCWWWF
%2CB099NSRP29%2CB08YYMG4X2%2CB07DJ2TP6H&srpt=COMPUTER_DRIVE_OR_STORAGE' -H 'user-agent: Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15
 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1'| pup 'span#atfRedesign_priceblock_priceToPay' | head -n 6 | tail -n 1 | tr -d ,)
  set fk (curl -s 'https://www.flipkart.com/crucial-bx500-240-gb-laptop-desktop-internal-solid-state-drive-ct240bx500ssd1/p/itm47385821d256d?pid=ACCFNFUKF9BKE5PS&lid
=LSTACCFNFUKF9BKE5PSURBYLC&marketplace=FLIPKART&q=ssd&store=6bo%2Fjdy&spotlightTagId=BestsellerId_6bo%2Fjdy&srno=s_1_3&otracker=search&otracker1=search&fm=SEARCH&iid
=6418dbd6-8f52-4990-be00-efc3b03396cc.ACCFNFUKF9BKE5PS.SEARCH&ppt=sp&ppn=sp&ssid=fieava78gg0000001634230842661&qH=d4576b3b305e1df6' -H 'User-Agent: Mozilla/5.0 (X11;
 Linux x86_64; rv:92.0) Gecko/20100101 Firefox/92.0'| pup 'div' | head -n 334|tail -n 1 | awk '{$1=$1};1' | cut -c4- | tr -d ,)

  if bash -c '[ "$amzn" = "$fk" ]' #doesnt work in fish so ;(
    echo $fk/FK
  else if bash -c '[ "$amzn" -gt "$fk" ]'
    echo $fk/FK
  else
    echo $amzn/AMZN
  end
end
