/*
 * Generated by Bluespec Compiler, version 2019.05.beta2 (build a88bf40db, 2019-05-24)
 * 
 * On Mon Feb  3 21:31:08 GMT 2020
 * 
 * To automatically register this VPI wrapper with a Verilog simulator use:
 *     #include "vpi_wrapper_c_debug_client_connect.h"
 *     void (*vlog_startup_routines[])() = { c_debug_client_connect_vpi_register, 0u };
 * 
 * For a Verilog simulator which requires a .tab file, use the following entry:
 * $imported_c_debug_client_connect call=c_debug_client_connect_calltf size=8 acc=rw:%TASK
 * 
 * For a Verilog simulator which requires a .sft file, use the following entry:
 * $imported_c_debug_client_connect vpiSysFuncSized 8 unsigned
 */
#include <stdlib.h>
#include <vpi_user.h>
#include "bdpi.h"

/* the type of the wrapped function */
char c_debug_client_connect(unsigned int );

/* VPI wrapper function */
PLI_INT32 c_debug_client_connect_calltf(PLI_BYTE8 *user_data)
{
  vpiHandle hCall;
  unsigned int arg_1;
  char vpi_result;
  vpiHandle *handle_array;
  
  /* retrieve handle array */
  hCall = vpi_handle(vpiSysTfCall, 0);
  handle_array = vpi_get_userdata(hCall);
  if (handle_array == NULL)
  {
    vpiHandle hArgList;
    hArgList = vpi_iterate(vpiArgument, hCall);
    handle_array = malloc(sizeof(vpiHandle) * 2u);
    handle_array[0u] = hCall;
    handle_array[1u] = vpi_scan(hArgList);
    vpi_put_userdata(hCall, handle_array);
    vpi_free_object(hArgList);
  }
  
  /* create return value */
  make_vpi_result(handle_array[0u], &vpi_result, DIRECT);
  
  /* copy in argument values */
  get_vpi_arg(handle_array[1u], &arg_1, DIRECT);
  
  /* call the imported C function */
  vpi_result = c_debug_client_connect(arg_1);
  
  /* copy out return value */
  put_vpi_result(handle_array[0u], &vpi_result, DIRECT);
  
  /* free argument storage */
  free_vpi_args();
  vpi_free_object(hCall);
  
  return 0;
}

/* sft: $imported_c_debug_client_connect vpiSysFuncSized 8 unsigned */

/* tab: $imported_c_debug_client_connect call=c_debug_client_connect_calltf size=8 acc=rw:%TASK */

PLI_INT32 c_debug_client_connect_sizetf(PLI_BYTE8 *user_data)
{
  return 8u;
}

/* VPI wrapper registration function */
void c_debug_client_connect_vpi_register()
{
  s_vpi_systf_data tf_data;
  
  /* Fill in registration data */
  tf_data.type = vpiSysFunc;
  tf_data.sysfunctype = vpiSizedFunc;
  tf_data.tfname = "$imported_c_debug_client_connect";
  tf_data.calltf = c_debug_client_connect_calltf;
  tf_data.compiletf = 0u;
  tf_data.sizetf = c_debug_client_connect_sizetf;
  tf_data.user_data = "$imported_c_debug_client_connect";
  
  /* Register the function with VPI */
  vpi_register_systf(&tf_data);
}