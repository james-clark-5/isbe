#include "ncm_scp_handler.h"

#include <nailfold/ncm_encrypt.h>

//
// Public member functions
//

ncm_scp_handler::ncm_scp_handler(vcl_string server /* = "" */, 
                                 vcl_string username /* = "" */, 
                                 vcl_string password /* = "" */)
: ncm_server_handler(server, username, password)
{
  connect();
}

//
// Private member functions
//

vcl_string ncm_scp_handler::connect_string() const
{
  return ncm_decrypt("��m���mР���m�" + password_);
}