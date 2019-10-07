package CACC_2017.week13;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;

public class HaofengSocketClient {
	private Socket clientSocket;
	private PrintWriter out;
	private BufferedReader in;

	public void startConnection(String ip, int port) throws Exception {
		clientSocket = new Socket(ip, port);
		out = new PrintWriter(clientSocket.getOutputStream(), true);
		in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));
	}

	public String sendMessage(String msg) throws Exception {
		out.println(msg);
		String resp = in.readLine();
		return resp;
	}

	public void stopConnection() throws Exception {
		in.close();
		out.close();
		clientSocket.close();
	}

	public static void main(String[] args) {
		try {
			HaofengSocketClient client = new HaofengSocketClient();
			client.startConnection("127.0.0.1", 8080);
			String response1 = client.sendMessage("hello server");
			System.out.println("[Client] "+response1);
		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}
}
