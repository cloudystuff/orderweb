#Connect-AzAccount

for ($i = 0; $i -lt 1; $i++) {
    
    $item = "Item $i"
    $quantity = $i

    $order = @{  item  = $item; 
        quantity = $quantity
    }

    $body = $order | ConvertTo-Json
    $orders = Invoke-RestMethod   -Method Post `
                        -ContentType "application/json" `
                        -Uri "https://orderweb.wittybeach-f1459f4a.westeurope.azurecontainerapps.io/" `
                        -Body $body
    #[System.Threading.Thread]::Sleep(50)
    "Sending message $i"
}