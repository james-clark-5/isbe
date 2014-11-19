#ifndef __NCM_FLOW_COST_FUNCTION_CHOLMOD_H__
#define __NCM_FLOW_COST_FUNCTION_CHOLMOD_H__

#include <vnl/vnl_vector.h>
#include <vnl/vnl_sparse_matrix.h>

#include <nailfold/flow/ncm_flow_cost_function.h>

class ncm_flow_robustifier;
class ncm_flow_field;

class ncm_flow_cost_function_cholmod
: public ncm_flow_cost_function
{
public: // methods

  //: Constructor
  ncm_flow_cost_function_cholmod(
    vcl_vector< vil_image_view<float> > const* image_stack,
    vcl_vector< vil_image_view<float> > const* warped_image_stack = NULL,
    ncm_flow_robustifier const* robustifier = NULL);

  //: Destructor
  ~ncm_flow_cost_function_cholmod();

  vnl_vector<double> f(
    vnl_vector<double> const& parameters);

  vnl_sparse_matrix<double> jacobian(
    vnl_vector<double> const& parameters);

protected: // variables

private: // methods

private: // variables

};

#endif __NCM_FLOW_COST_FUNCTION_CHOLMOD_H__