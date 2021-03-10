//$(document).ready(function() {
//    $('#btnSun').click(SearchByHostingType);
//});

$(document).ready(function() {
    $('#btnSun').click(function() {
        $('#filter').submit(function(e) {
            e.preventDefault();
            var datastring = $( this ).serializeArray();
            SearchByHostingType(datastring);
        }) 
    })
});

function SearchByHostingType(data) {
    //  https://docs.aws.amazon.com/sdk-for-javascript/v2/developer-guide/welcome.html#welcome_web
    
    var hosting_type = "Todos"
    var monthly_price = 9999
    var domain_included = "Todos"
    $(data).each(function(i, field){
        switch(field.name) {
            case 'HostingType':
                hosting_type = field.value
                break;
            case 'MonthlyPrice':
                monthly_price = field.value
                break;
            case 'DomainIncluded':
                domain_included = field.value
                break;
            default:
                alert('ERROR getting params from form: '+field.name)
        }
    });

    var payload={
        "HostingType": hosting_type,
        "MonthlyPrice": monthly_price,
        "DomainIncluded": domain_included
    };

    var result="";
    $.ajax({
        type: 'POST',
        //url: "http://127.0.0.1:3000/search",
        url: "https://api.quehosting.es/dev/search",
        data: JSON.stringify(payload),
        dataType: 'json',
        //headers: { 'Content-Type': 'application/json' },
        crossDomain: true,
        success:function(data) {
            var div_result=document.getElementById("search-result");
            if (data.length == 0) {
                // NO results
                div_result.innerHTML="No se han encontrado resultados"
            } else {
                var items = data['message']
                var html = ""
                if ( items.length == 0 ) {
                    html = "No se han encontrado resultados"
                } else {
                    for (var k in items) {
                        // https://www.w3schools.com/jquery/jquery_dom_add.asp
                        var html = html  + SetHtmlForAnItem(items[k])
                    }
                }
                div_result.innerHTML=html
            }
        },
        error:function (xhr, ajaxOptions, thrownError){
            alert(xhr);
            var div_result=document.getElementById("search-result");
            if(xhr.status==404) {
                div_result.innerHTML = 'Item not found'
            }
            else {
                div_result.innerHTML = 'Unexpected error'
            }
        }
   });
}

function Normalize(item) {
    if (item == "99999") {
        return "<strong>Ilimitado</strong>"
    } 
    else {
        return item
    }
}

function GetHtmlForProviderLogo(provider) { 
    var provider_no_blanks = provider.replace(/\s/g, '');
    return "<img src='img/" + provider_no_blanks.toLowerCase() + ".png' alt='" + provider + "' />"
 }

function GetHtmlStartForAColumn() {
    return "\
    <div class='col-sm'> \
        <ul class='list-unstyled mt-3 mb-4'>"
}

function GetHtmlEndForAColumn() {
    return "\
        </ul> \
    </div> <!--// float: left -->"
}

function compare(one, two) {
    const a = one.PriceMonth;
    const b = two.PriceMonth;
  
    let comparison = 0;
    if (a < b) {
      comparison = 1;
    } else if (a > b) {
      comparison = -1;
    }
    return comparison;
}

function GetCorrectLanguageForMonths(months) {
    var text = "m"
    if (months == "1") {
        text = "mes"
    }
    return months + " " + text
}

function GetHtmlDetailedPrice(currency, min_price, all_prices) {
    var html = "<h1 class='card-title pricing-card-title text-right'>" + min_price + currency + "<small class='text-muted'>/ mes</small></h1>"
    if (all_prices) {
        all_prices_sorted = all_prices.sort(compare)
        html = html + "<div class='container' style='margin-bottom: 10px;'><div class='row justify-content-center' style='white-space: nowrap; overflow: hidden;'>"
        for (price of all_prices_sorted) {
            html = html + "<div class='col' style='background-color: rgba(0, 0, 0, 0.03); border-bottom: 1px solid rgba(0, 0, 0, 0.125);'>" + GetCorrectLanguageForMonths(price.Months) + "</div>"
        }
        html = html + "<div class='w-100'></div>"
        for (price of all_prices_sorted) {
            html = html + "<div class='col' style='border-bottom: 1px solid rgba(0, 0, 0, 0.125);'><strong>" + price.PriceMonth + currency + "</strong></div>"
        }
        html = html + "<div class='w-100'></div>"
        for (price of all_prices_sorted) {
            if (price.Save) {
                html = html + "<div class='col' style='border-bottom: 1px solid rgba(0, 0, 0, 0.125);'>-" + price.Save + "%</div>"
            }
            else {
                html = html + "<div class='col' style='border-bottom: 1px solid rgba(0, 0, 0, 0.125);'></div>"
            }
        }
        html = html + "</div></div>"
    }
    html = html + "<button type='button' class='btn btn-lg btn-block btn-primary'>Contratar</button>"
    return html
}

function GetHtmlSimplePrice(currency, min_price, url) {
    var html = "<div class='card-title pricing-card-title text-right'>desde <span style='font-size: x-large; font-weight: bolder;'>" + min_price + currency + "</span>/ mes</div>"
    html = html + "<a href='" + url + "' type='button' class='btn btn-lg btn-block btn-primary' target='_blank'>Contratar</a>"
    return html
}

function GetHtmlDiskSize(size, type) {
    var html = ""
    if (size) {
        html = "<li>" + Normalize(size) + " GB de disco"
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
                html = html + "Dominio incluido</li>"
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

/* Generates the "support type" HTML section 
 *
 * Params:
 *   support_list: a string which is actually a list of support types
 */
function GetHtmlForSupport(support_list) {
    if (! support_list) {
        return ""
    }
    var html = "<li style='margin-top: 10px;'>Soporte técnico</li><li>"
    var support = support_list.split(",")
    for (i = 0; i < support.length; i++) {
        switch(support[i]) {
            case "Chat":
                html = html + "<img src='img/chat.svg' alt='Chat de soporte en línea' style='height: 25px; margin-right: 15px;' />"
                break;
            case "Email":
                html = html + "<img src='img/email.svg' alt='Soporte via email' style='height: 25px; margin-right: 15px;' />"
                break;
            case "Phone":
                html = html + "<img src='img/phone.svg' alt='Soporte telefónico' style='height: 25px; margin-right: 15px;' />"
                break;
            case "Ticket":
            default:
                html = html + "<img src='img/ticket.svg' alt='Soporte mediante sistema de tickets' style='height: 25px; margin-right: 15px;' />"
        }
    }
    return html + "</li>"
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
            <h4 class='my-0 font-weight-normal' style='float:right'>Plan " + hosting_type + " " + hosting_plan + "</h4> \
            <h4 class='my-0 font-weight-normal' style='float:left'>" + GetHtmlForProviderLogo(provider) + "</h4> \
        </div> \
        <div class='container card-body'> \
            <div class='row'>"

    // COLUMN 1 - SITES, DISK, DATABASES
    html = html + GetHtmlStartForAColumn()
    html = html 
            + GetHtmlWebNumber(item['WebNumber'])
            + GetHtmlDiskSize(item['DiskSize'], item['DiskType'])
            + GetHtmlDatabase(item['DatabaseNumber'], item['DatabaseSize'])
    html = html + GetHtmlEndForAColumn()

    // COLUMN 2 - DOMAINS, SSL
    html = html + GetHtmlStartForAColumn()
    html = html 
            + GetHtmlDomains(item['DomainIncluded'], item['DomainsParked'], item['DomainSubdomain'])
            + GetHtmlSSL(item['SslCertificate'])
            + GetHtmlForSupport(item['SupportList'])
    html = html + GetHtmlEndForAColumn()

    // COLUMN 3 - PRICE
    html = html + GetHtmlStartForAColumn()
    html = html 
            + GetHtmlSimplePrice(item['Currency'], item['PaymentMonthMin'], item['Url'])
    html = html + GetHtmlEndForAColumn()

    // END
    html = html + "\
            </div> <!--// row --> \
        </div> <!--// container card-body --> \
    </div>"

    return html
}