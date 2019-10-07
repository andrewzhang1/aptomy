package CACC_2017.week13;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;

public class HaofengSocketClient_LongLasting {
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
			HaofengSocketClient_LongLasting client = new HaofengSocketClient_LongLasting();
			client.startConnection("127.0.0.1", 8080);
			String response1 = client.sendMessage("hello server");
			System.out.println("[Client] "+response1);
		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}

//	public static void main(String[] args) {
//		try {
//			HaofengSocketClient client = new HaofengSocketClient();
//			client.startConnection("127.0.0.1", 6666);
//			String response = client.sendMessage("hello server");
//			System.out.println("[Client] "+response);
//		} catch (Exception ex) {
//			ex.printStackTrace();
//		}
//	}
//
//	public static void main(String[] args) {
//		try {
//			HaofengSocketClient client = new HaofengSocketClient();
//			client.startConnection("10.141.80.173", 6667);
////			client.startConnection("127.0.0.1", 6666);
//			String response1 = client.sendMessage("hello server");
//			String response2 = client.sendMessage("we are class CP-101");
//			String response3 = client.sendMessage("we are learning Java networking");
//			String response4 = client.sendMessage("Java is fun");
//			String response5 = client.sendMessage(".");
//			System.out.println("[Client] "+response1);
//			System.out.println("[Client] "+response2);
//			System.out.println("[Client] "+response3);
//			System.out.println("[Client] "+response4);
//			System.out.println("[Client] "+response5);
//		} catch (Exception ex) {
//			ex.printStackTrace();
//		}
//	}
}
