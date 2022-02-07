//
//  PostTableViewCell.swift
//  RxInstaSample
//
//  Created by take on 2022/02/04.
//

import UIKit
import RxSwift

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    var disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }

    // PostDataの内容をセルに表示
    func setPostData(_ postData: PostDataProtocol) {
        // 画像の表示
        postImageView.setStorageImage(fileName: postData.id + ".jpg")

        // タイトルの表示
        self.titleLabel.text = "\(postData.name) : \(postData.title)"

        // 日付の表示
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        if let date = postData.date {
            self.dateLabel.text = dateFormatter.string(from: date)
        } else {
            self.dateLabel.text = ""
        }

        // いいね数の表示
        let likeNumber = postData.likedUsers.count
        likeLabel.text = "「いいね!」\(likeNumber)件"

        // いいねボタンの表示
        if postData.isLiked {
            let config = UIImage.SymbolConfiguration.preferringMulticolor()
            let image = UIImage(systemName: "heart.fill", withConfiguration: config)
            self.likeButton.setImage(image, for: .normal)
        } else {
            let config = UIImage.SymbolConfiguration(paletteColors:[.systemGray4])
            let image = UIImage(systemName: "heart", withConfiguration: config)
            self.likeButton.setImage(image, for: .normal)
        }
    }
}
