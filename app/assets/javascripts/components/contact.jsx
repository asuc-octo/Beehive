class Contact extends React.Component {
    render() {
       return <div><div className="row">
                <dl className="dl-horizontal">
                    <dt>
                    <label htmlFor="sender">Reply To:</label>
                    </dt>
                    <dd>
                    <input className="form-control" id="sender" name="sender" type="text" value={this.props.email}/>
                    </dd>
                    <dt>
                    <label htmlFor="subject">Subject:</label>
                    </dt>
                    <dd>
                    <input className="form-control" id="subject" name="subject" placeholder="Enter subject..." type="text" />
                    </dd>
                    <dt className="body">
                    <label htmlFor="body">Message:</label>
                    </dt>
                    <dd>
                    <textarea className="form-control" id="body" name="body" placeholder="Enter feedback..." rows="10"></textarea>
                    </dd>
                </dl>
                </div>
                <input className="btn btn-primary" type="submit" value="Send Message"/></div>
    }
}

// class SendButton extends React.Component {
//     render() {
//         return <a href={this.props.path} class="btn btn-primary">{this.props.label}</a>
//     }
// }
