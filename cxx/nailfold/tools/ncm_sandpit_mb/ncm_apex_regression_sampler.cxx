#include "ncm_apex_regression_sampler.h"
#include "ncm_base_iih_patch_trainer.h"

ncm_apex_regression_sampler::ncm_apex_regression_sampler()
	:	MAXLEN(255),
		num_images_( 100 ),
		samples_per_image_( 100 )
{
}

bool ncm_apex_regression_sampler::process_args(int argc, char* argv[])
{ 
	img_dir_ = "C:/isbe/nailfold/data/training/syn_patches/";
	pts_dir_ = "C:/isbe/nailfold/data/training/syn_patch_apexes/";
	data_path_ = "C:/isbe/nailfold/data/training/syn_patch_data/sample.dat";
	img_base_name_ = "apex";

	img_dir_ += img_base_name_;
	pts_dir_ += img_base_name_;

	num_images_ = 100;
	samples_per_image_ = 100;
	return true;
}

//
//: Load an image file
bool ncm_apex_regression_sampler::readInitialPtsFile(const vcl_string& fname, vcl_vector<vgl_point_2d<double>>& gt_apex)
{
	vcl_string path = fname;
  
	vcl_ifstream * afs = new vcl_ifstream(path.c_str());
  
	if (afs==0 || !(*afs))
	{
		vcl_cerr<<"Couldn't open "<<path<<vcl_endl;
		delete afs;
		return false;
	}
  
	char *label = new char[MAXLEN];
	char *str1 = new char[MAXLEN];
	
	while ((*afs)>>vcl_ws, !(*afs).eof())
	{
		(*afs)>>label;
    
		if ( (label[0]=='/') &&( label[1]=='/') )
		{
			// Comment line, so read to end
			afs->getline(str1,MAXLEN);
			vcl_cout<<"Comment read from file: " << str1 << vcl_endl;
		}
		else if (strcmp(label,"version:")==0 || strcmp(label,"n_points:")==0)
		{
			// Read in value of goat
			afs->getline(str1,MAXLEN);
			vcl_cout<<"Line read from file: " << str1 << vcl_endl;
		}
		else if (strcmp(label,"{")==0)
		{
				double apex_x;
				double apex_y;

				for (int i = 0; i <= 30; i++) {
					(*afs)>>apex_x;
					(*afs)>>apex_y;
					gt_apex[i ] = vgl_point_2d<double> (apex_x, apex_y);
				
				}
		}
		else if (strcmp(label,"}")==0)
			break;
	}

	//Tidy up and return
	delete [] label;
	delete [] str1;
  
	delete afs;
	return true;
}

//
// Main function
int ncm_apex_regression_sampler::main_fun( int argc, char* argv[] )
{
	process_args(argc, argv);
	
	//Create IO object to load images
	/*vsml_uint16 image_2d_io<double> im_io;*/
	vsml_byte_image_2d_io im_io;
	
	//Create datastream to write out samples - write out the total no of samples on the first line
	vsl_b_ofstream bfs( data_path_ );
	vsl_b_write(bfs, unsigned( num_images_ * samples_per_image_ ));

	//Loop through the training images
	for (int i = 1; i <= num_images_; i++) {

		vcl_string img_path = img_dir_;
		vcl_string pts_path = pts_dir_;

		//Set up the complete name for this image and associated points file
		vcl_stringstream im_ss;
		im_ss << vcl_setw( 4 ) << vcl_setfill( '0' ) << i;
			
		img_path += im_ss.str();
		pts_path += im_ss.str();

		img_path += ".png";
		pts_path += ".pts";
			
		//Create image object then try and load it
		//vimt_image_2d_of<double> nailfold_image;
		vimt_image_2d_of<vxl_byte> nailfold_image;
		bool img_loaded = im_io.loadTheImage( nailfold_image, img_path, "" );
		if (!img_loaded)
		{
			vcl_cout << img_path << " failed to load!" << vcl_endl;
			continue;
		}
		vcl_cout << img_path << " loaded ok!" << vcl_endl;

		//Load in the initial apex
		vcl_vector<vgl_point_2d<double> > gt_apex( 31 );
		bool pts_loaded = readInitialPtsFile( pts_path, gt_apex );
		if (!pts_loaded)
		{
			vcl_cout << pts_path << " failed to load!" << vcl_endl;
			continue;
		}
		vcl_cout << pts_path << " loaded ok!" << vcl_endl;

		//Create a patch trainer object
		ncm_base_iih_patch_trainer patch_trainer;
		patch_trainer.setSamplesPerImage( samples_per_image_ );

		//Set the trainer's output stream and image, the generate data given ground truth apex
		patch_trainer.setStream( &bfs );
		vcl_cout << "Patch trainer stream set" << vcl_endl;
		patch_trainer.setImage( nailfold_image );
		vcl_cout << "Patch trainer image set" << vcl_endl;
		patch_trainer.generateTrainingData( gt_apex[ 15 ] );
		vcl_cout << "Patch trainer data sampled" << vcl_endl;
								
	}
	bfs.close();
	return 0;
}



