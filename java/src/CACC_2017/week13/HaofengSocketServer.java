package CACC_2017.week13;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.ServerSocket;
import java.net.Socket;

public class HaofengSocketServer {
	private ServerSocket serverSocket;
	private Socket clientSocket;
	private PrintWriter out;
	private BufferedReader in;

	public void start(int port) throws Exception {
		serverSocket = new ServerSocket(port);
		clientSocket = serverSocket.accept();
		out = new PrintWriter(clientSocket.getOutputStream(), true);
		in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));
		String greeting = in.readLine();
		if ("hello server".equals(greeting)) {
			out.println("hello client");
		} else {
			out.println("unrecognised greeting");
		}
	}

	public void stop() throws Exception {
		in.close();
		out.close();
		clientSocket.close();
		serverSocket.close();
	}

	public static void main(String[] args) {
		try {
			HaofengSocketServer server = new HaofengSocketServer();
			server.start(8080);
			server.stop();
		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}
}
