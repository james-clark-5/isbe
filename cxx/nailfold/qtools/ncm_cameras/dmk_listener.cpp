//////////////////////////////////////////////////////////////////////
// Listener.cpp: implementation of the CListener class.
//
//////////////////////////////////////////////////////////////////////
#include "dmk_listener.h"

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CListener::CListener()
{
	//m_pParent = NULL;
	//m_pDrawCWnd = NULL;
	//Register mem_buffer class so it can be queued by QT
	qRegisterMetaType< smart_ptr<MemBuffer> >("smart_ptr<MemBuffer>");
}

//////////////////////////////////////////////////////////////////////////

CListener::~CListener() 
{
}

//////////////////////////////////////////////////////////////////////////

//void CListener::SetParent( QMainWindow *gui )
//{
//	dmk_gui_ = (dmk_qcapture_gui *) gui;
//}

//////////////////////////////////////////////////////////////////////////
// Notify parent, device is lost.
//////////////////////////////////////////////////////////////////////////

void CListener::deviceLost( Grabber& param) 
{
	//if( m_pParent != NULL)
		//m_pParent->PostMessage(MESSAGEDEVICELOST,0,0);
}

//////////////////////////////////////////////////////////////////////////
// Callback handler.
//////////////////////////////////////////////////////////////////////////

void CListener::frameReady( Grabber& param, smart_ptr<MemBuffer> mem_buffer, DWORD FrameNumber)
{
	//Get time
	QTime curr_time = QTime::currentTime();
	mem_buffer->lock();

	//dmk_gui_->setQImage( mem_buffer, false);
	//dmk_gui_->redraw_scene();
	//vcl_cout << "redrawn scene" << vcl_endl;
	emit frame_ready( mem_buffer, curr_time);
	//emit frame_ready();
	mem_buffer->unlock();
}

//////////////////////////////////////////////////////////////////////////
// Draw the image buffer into the DrawCWnd.
//////////////////////////////////////////////////////////////////////////

void CListener::DrawBuffer( smart_ptr<MemBuffer> pBuffer)
{
	
}
//////////////////////////////////////////////////////////////////////////
// The image processing is done here. For the sake of simplicity, the
// image data is inverted by this sample code.
//////////////////////////////////////////////////////////////////////////

void CListener::DoImageProcessing( smart_ptr<MemBuffer> pBuffer)
{

}

//void CListener::frame_ready(smart_ptr<MemBuffer> &mem_buffer)
//{
//
//}
