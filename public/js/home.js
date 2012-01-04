function setInput(input_field)
{
  if(input_field.value == input_field.defaultValue)
  {
    input_field.value = '';
  }
  input_field.className = 'title';
}

function validate(formData, jqForm, options) {  
    var form = jqForm[0]; 
    var address = (form.address.value == form.address.defaultValue) ? "" : form.address.value;
    var info    = (form.info.value == form.info.defaultValue) ? "" : form.info.value;

    if(address) clearError('div#address-container');
    if(info) clearError('div#info-container');

    if (info && address) {
      // sanitize address
      var santized_address = address.replace(RegExp('^\/|\/$', 'gm'), "");   
      // change method
      var new_action = '/write/' + santized_address;
      form.setAttribute('action', new_action);
      form.submit();
    }
    else
    { 
      if(!info) showError(form.info, 'div#info-container');
      if(!address) showError(form.address, 'div#address-container');
      return false; 
    } 

}

function showError(input_field, container_div)
{
  $(container_div).addClass('error');
  input_field.value = ''; 
  input_field.className = 'title';
}

function clearError(container_div) 
{
  $(container_div).removeClass('error');
}

