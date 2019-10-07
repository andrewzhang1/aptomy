package CACC_2017.week13;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.ServerSocket;
import java.net.Socket;

public class HaofengSocketServer_LongLasting {
	private ServerSocket serverSocket;
	private Socket clientSocket;
	private PrintWriter out;
	private BufferedReader in;

	public void start(int port) throws Exception {
		serverSocket = new ServerSocket(port);
		while(true){
			clientSocket = serverSocket.accept();
			out = new PrintWriter(clientSocket.getOutputStream(), true);
			in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));

			String inputLine;
			while ((inputLine = in.readLine()) != null) {
				if (".".equals(inputLine)) {
					out.println("good bye");
					break;
				}
				out.println(inputLine);
			}
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
			HaofengSocketServer_LongLasting server = new HaofengSocketServer_LongLasting();
			server.start(6667);
			server.stop();
		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}
}
