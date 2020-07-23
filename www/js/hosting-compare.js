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
            alert(JSON.stringify(data, null, 2));
            var div_result=document.getElementById("test-result");
            if (data.length == 0) {
                // NO results
                div_result.innerHTML="No se han encontrado resultados"
            } else {
                var items = data['message']
                var html = ""
                for (var k in items) {
                    // https://www.w3schools.com/jquery/jquery_dom_add.asp
                    var html = html + SetHtmlForAnItem(items[k])
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

/* Creates the HTML code for an item and returns the HTML code ready to be used
 *
 * Params:
 *   item: the json object including all item attributes
 */
function SetHtmlForAnItem(item) {
    var hosting_plan = item['HostingPlan']
    var provider = item['Provider']
    var min_payment_month = item['MinPaymentMonth']

    var html = "\
    <div class='card mb-4 shadow-sm'> \
    <div class='card-header'> \
      <h4 class='my-0 font-weight-normal'>" + provider + " " + hosting_plan + "</h4> \
    </div> \
    <div class='card-body'> \
      <h1 class='card-title pricing-card-title'>$" + min_payment_month + "<small class='text-muted'>/ mo</small></h1> \
      <ul class='list-unstyled mt-3 mb-4'> \
        <li>30 users included</li> \
        <li>15 GB of storage</li> \
        <li>Phone and email support</li> \
        <li>Help center access</li> \
      </ul> \
      <button type='button' class='btn btn-lg btn-block btn-primary'>Contact us</button>  \
    </div>"

    return html
}