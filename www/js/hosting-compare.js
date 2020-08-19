$(document).ready(function() {
    $('#btnSun').click(SearchByHostingType);
});

function SearchByHostingType() {
    /*  https://docs.aws.amazon.com/sdk-for-javascript/v2/developer-guide/welcome.html#welcome_web
    */
    var payload={
        "HostingType": "Wordpress"
    };

    var result="";
    $.ajax({
        type: 'POST',
        url: "http://127.0.0.1:3000/search",
        data: JSON.stringify(payload),
        dataType: 'json',
        headers: { 'Content-Type': 'application/json' },
        crossDomain: true,
        success:function(data) {
            //alert(JSON.stringify(data, null, 2));
            var div_result=document.getElementById("test-result");
            if (data.length == 0) {
                // NO results
                div_result.innerHTML="No se han encontrado resultados"
            } else {
                var items = data['message']
                var html = ""
                for (var k in items) {
                    // https://www.w3schools.com/jquery/jquery_dom_add.asp
                    var html = html  + SetHtmlForAnItem(items[k])
                }
                div_result.innerHTML=html
            }
        },
        error:function (xhr, ajaxOptions, thrownError){
            alert(xhr);
            var div_result=document.getElementById("test-result");
            if(xhr.status==404) {
                div_result.innerHTML = 'Item not found'
            }
            else {
                div_result.innerHTML = 'Unexpected error'
            }
        }
   });
}

/* Transforms the input value to a human friendly one
 *
 * Params:
 *   item: the pa
 */
function Normalize(item) {
    if (item == "99999") {
        return "<strong>Ilimitado</strong>"
    } 
    else {
        return item
    }
}

function GetHtmlStartForAColumn() {
    return "\
    <div style='float: left; margin-right: 20px;'> \
        <ul class='list-unstyled mt-3 mb-4'>"
}

function GetHtmlEndForAColumn() {
    return "\
        </ul> \
    </div> <!--// float: left -->"
}

function GetHtmlPrice(currency, min_price, all_prices) {
    return "\
    <div style='float:right;'> \
        <h1 class='card-title pricing-card-title'>" + min_price + currency + "<small class='text-muted'>/ mes</small></h1> \
        <button type='button' class='btn btn-lg btn-block btn-primary'>Contact us</button> \
    </div>"
}

function GetHtmlDiskSize(size, type) {
    var html = ""
    if (size) {
        html = "<li>" + Normalize(size) + " GB de espacio en disco"
        if (type) {
            html = html + " " + type
        }
        html = html + "</li>"
    }
    return html
}

function GetHtmlWebNumber(web_number) {
    var html = ""
    if (web_number){
        html = "<li>" + Normalize(web_number) + " sitios web</li>"
    }
    return html
}

function GetHtmlDatabase(number, size) {
    var html = ""
    if (number) {
        html = "<li>" + Normalize(number) + " bases de datos"
        if (size) {
            html = html + " de " + Normalize(size) + " GB"
        }
        html = html + "</li>"
    } 
    return html
}

function GetHtmlDomains(included, parked, subdomain) {
    var html = ""
    if (included) {
        html = "<li>"
        switch(included) {
            case "year":
                html = html + "Dominio 1r año gratis</li>"
                break;
            case "true":
                html = html + "Dominio incluido para siempre</li>"
                break;
            default:
                html = html + "Dominio no incluido</li>"
                break;
        }

        if (parked) {
            html = html + "<li>" + Normalize(parked) + " dominios parqueados</li>"
        }

        if (subdomain) {
            html = html + "<li>" + Normalize(subdomain) + " subdominios</li>"
        }
    }
    return html
}

function GetHtmlSSL(ssl) {
    var html = ""
    if (ssl) {
        html = "<li>"
        switch(ssl) {
            case "year":
                html = html + "Certificado SSL 1r año gratis</li>"
                break;
            case "true":
                html = html + "Certificado SSL incluido</li>"
                break;
            default:
                html = html + "Certificado SSL no incluido</li>"
                break;
        }
    }
    return html
}

/* Creates the HTML code for an item and returns the HTML code ready to be used
 *
 * Params:
 *   item: the json object including all item attributes
 */
function SetHtmlForAnItem(item) {
    var currency = item['Currency']
    var hosting_plan = item['HostingPlan']
    var hosting_type = item['HostingType']
    var provider = item['Provider']
    var min_payment_month = item['PaymentMonthMin']

    // HEADER
    var html = "\
    <div class='card mb-4 shadow-sm'> \
        <div class='card-header'> \
            <h4 class='my-0 font-weight-normal' style='float:right'>" + hosting_type + " " + hosting_plan + "</h4> \
            <h4 class='my-0 font-weight-normal' style='float:left'>" + provider + "</h4> \
        </div> \
        <div class='card-body'>"
    
    // CULUMN RIGHT (PRICE)
    html = html + GetHtmlPrice(item['Currency'], item['PaymentMonthMin'], item['PaymentMonth'])

    // COLUMN - SITES, DISK, DATABASES
    html = html + GetHtmlStartForAColumn()
    html = html 
            + GetHtmlWebNumber(item['WebNumber'])
            + GetHtmlDiskSize(item['DiskSizeGB']['Size'], item['DiskSizeGB']['Type'])
            + GetHtmlDatabase(item['DatabaseNumber'], item['DatabaseSizeGB'])
    html = html + GetHtmlEndForAColumn()

    // COLUMN - DOMAINS, SSL
    html = html + GetHtmlStartForAColumn()
    html = html 
            + GetHtmlDomains(item['DomainIncluded'], item['DomainsParked'], item['DomainSubdomain'])
            + GetHtmlSSL(item['Ssl'])
    html = html + GetHtmlEndForAColumn()

    // END
    html = html + "\
        </div> <!--// card-body --> \
    </div>"

    return html
}