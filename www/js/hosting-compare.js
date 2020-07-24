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
            alert(data);
            result = data; 
            var div_result=document.getElementById("test-result");
            if (result.length == 0) {
                // NO results
                div_result.innerHTML="No se han encontrado resultados"
            } else {
                for (item in result['message']) {
                    var hosting_plan = item['HostingPlan']
                    var provider = item['Provider']
                    var min_payment_month = item['MinPaymentMonth']
                    var html = "<h1>"+ provider + " | " + hosting_plan + " | " + min_payment_month + "</h1>"
                    // https://www.w3schools.com/jquery/jquery_dom_add.asp
                    div_result.innerHTML=html
                }
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

function SearchByHostingTypeJquery() {
    /*  https://docs.aws.amazon.com/sdk-for-javascript/v2/developer-guide/welcome.html#welcome_web
    */
    var payload={
        "HostingType": "Wordpress"
    };

    var result="";
    $.post({
        url: "http://127.0.0.1:3000/search",
        data: JSON.stringify(payload),
        dataType: 'json',
        headers: { 'Content-Type': 'application/json' },
        crossDomain: true,
        success:function(data) {
            alert(data);
            result = data; 
            var div_result=document.getElementById("test-result");
            if (result.length == 0) {
                // NO results
                div_result.innerHTML="No se han encontrado resultados"
            } else {
                for (item in result) {
                    var hosting_plan = item['HostingPlan']
                    var provider = item['Provider']
                    var min_payment_month = item['MinPaymentMonth']
                    var html = "<h1>"+ provider + " | " + hosting_plan + " | " + min_payment_month + "</h1>"
                    // https://www.w3schools.com/jquery/jquery_dom_add.asp
                    div_result.innerHTML=html
                }
            }
        },
        error:function (xhr, ajaxOptions, thrownError){
            alert(xhr.status);
            var div_result=document.getElementById("test-result");
            if(xhr.status==404) {
                div_result.innerHTML = 'Item not found'
            }
            else {
                div_result.innerHTML = 'That Unexpected error'
            }
        }
   });
}