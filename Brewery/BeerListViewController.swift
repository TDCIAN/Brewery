//
//  ViewController.swift
//  Brewery
//
//  Created by JeongminKim on 2022/03/30.
//

import UIKit

class BeerListViewController: UITableViewController {
    var beerList: [Beer] = []
    var dataTasks: [URLSessionTask] = []
    var currentPage = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "브루어리"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.register(BeerListcell.self, forCellReuseIdentifier: BeerListcell.identifier)
        tableView.rowHeight = 150
        tableView.prefetchDataSource = self
        
        fetchBeer(of: currentPage)
    }
}

extension BeerListViewController: UITableViewDataSourcePrefetching {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beerList.count
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard currentPage != 1 else { return }
        indexPaths.forEach {
            if ($0.row + 1)/25 + 1 == currentPage {
                self.fetchBeer(of: currentPage)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Rows: \(indexPath.row)")
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: BeerListcell.identifier,
            for: indexPath
        ) as? BeerListcell else {
            return UITableViewCell()
        }
        let beer = beerList[indexPath.row]
        cell.configure(with: beer)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedBeer = beerList[indexPath.row]
        let detailViewController = BeerDetailViewController()
        detailViewController.beer = selectedBeer
        self.show(detailViewController, sender: nil)
    }
}

private extension BeerListViewController {
    func fetchBeer(of page: Int) {
        guard let url = URL(string: "https://api.punkapi.com/v2/beers?page=\(page)"),
              dataTasks.firstIndex(where: { $0.originalRequest?.url == url }) == nil else { return } // 한 번도 사용되지 않은 URLSessionTask여야 함
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let dataTask = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard error == nil,
                  let self = self,
                  let response = response as? HTTPURLResponse,
                  let data = data,
                  let beer = try? JSONDecoder().decode([Beer].self, from: data) else {
                      print("ERROR - URLSession: \(String(describing: error))")
                      return
                  }
            
            switch response.statusCode {
            case (200...299):
                self.beerList += beer
                self.currentPage += 1
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case (400...499):
                print("Client Error: \(String(describing: error))")
            case (500...599):
                print("Server Error: \(String(describing: error))")
            default:
                print("Error: \(String(describing: error))")
            }
        }
        dataTask.resume()
        dataTasks.append(dataTask) // 같은 데이터태스크가 중복으로 네트워크 작업을 하는 것을 막기 위함
    }
}
