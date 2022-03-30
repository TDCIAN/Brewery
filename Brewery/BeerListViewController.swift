//
//  ViewController.swift
//  Brewery
//
//  Created by JeongminKim on 2022/03/30.
//

import UIKit

class BeerListViewController: UITableViewController {

    var beerList: [Beer] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "브루어리"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.register(BeerListcell.self, forCellReuseIdentifier: BeerListcell.identifier)
        tableView.rowHeight = 150
    }
}

extension BeerListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beerList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
