// msgpackerTest.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <iostream>
#include <string>
#include <sstream>
#include "msgpack.hpp"

//using win32
#include <stdio.h>
#include <WinSock2.h>
#include <WS2tcpip.h>

//using boost
#include <ctime>
#include <memory>
#include <functional>
#include <boost\bind.hpp>
#include <boost\asio.hpp>
#include <boost\lexical_cast.hpp>
using namespace std;
using boost::asio::ip::tcp;

void process_client(shared_ptr<tcp::socket> client, const string str)
{
	time_t now = time(0);
	//shared_ptr<string> message(new string(ctime(&now)));
	
	msgpack::type::tuple<int, bool, string> src(1, true, str/*"example"*/);
	stringstream buffer;
	msgpack::pack(buffer, src);
	buffer.seekg(0);
	//buffer << 1;
	//buffer << true;
	//buffer << "msg:debug:1";

	const string& cacheString = buffer.str();
	cout << "before message:" << cacheString << endl;
	shared_ptr<string> message(new string(cacheString + "\n"));
	cout << "after message:" << *message << endl;

	auto callback = [=](const boost::system::error_code& err, size_t size)
	{
		if ((int)size == message->length())
		{
			cout << "Write completed" << endl;
		}
	};

	//shared_ptr<string> buffer;
	//client->async_read_some(buffer, boost::bind(NULL));

	client->async_send(boost::asio::buffer(*message), callback);
}

void wrapper(shared_ptr<tcp::socket> client, string str)
{
	process_client(client, str);
}

typedef function<void(const boost::system::error_code&)> accept_callback;

void start_accept(tcp::acceptor & server)
{
	shared_ptr<tcp::socket> client(new tcp::socket(server.get_io_service()));
	accept_callback callback = [&server, client](const boost::system::error_code& error)
	{
		if (!error)
		{
			process_client(client, "msg:debug:0");

			process_client(client, "msg:debug:1");
		}
		start_accept(server);
	};

	server.async_accept(*client, callback);
}

int _tmain(int argc, _TCHAR* argv[])
{
	cout << "test msgpacker" << endl;

	//begin
	msgpack::type::tuple<int, bool, string> src(1, true, "example");
	stringstream buffer;
	msgpack::pack(buffer, src);
	buffer.seekg(0);

	string str(buffer.str());
	msgpack::object_handle oh = msgpack::unpack(str.data(), str.size());
	msgpack::object deserialized = oh.get();

	cout << deserialized << endl;

	//boost
	using boost::lexical_cast;
	int intStr = lexical_cast<int>("123");
	cout << "intStr:" << intStr << endl;

	try
	{
		boost::asio::io_service io_service;
		tcp::acceptor acceptor(io_service, tcp::endpoint(tcp::v4(), 12345));
		start_accept(acceptor);
		io_service.run();
	}
	catch (std::exception& e)
	{
		cerr << e.what() << endl;
	}

	return 0;
}

